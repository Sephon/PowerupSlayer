extends Area2D

@onready var sprite = $Sprite2D
@onready var glow = $Glow
var has_been_opened = false
var original_scale: Vector2
var iron_scrap_amount := 1
var pickup_range := 50.0
var player: Node2D
var is_collected := false

func _ready():
	# Connect the body entered signal
	body_entered.connect(_on_body_entered)
	original_scale = sprite.scale
	
	# Start with a small scale and grow
	sprite.scale = Vector2(0.1, 0.1)
	var tween = create_tween()
	tween.tween_property(sprite, "scale", original_scale, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Find player
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		player = players[0]

func _process(_delta):
	if is_collected:
		return
		
	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance <= pickup_range:
			collect()

func _on_timer_timeout():
	# Pulse the glow
	var tween = create_tween()
	tween.tween_property(glow, "energy", 0.8, 0.5)
	tween.tween_property(glow, "energy", 0.5, 0.5)

func _on_body_entered(body):
	if is_collected:
		return
		
	if body.is_in_group("players"):
		collect()

func collect():
	if is_collected:
		return
		
	is_collected = true
	
	# Add iron scrap to player's inventory
	if player.has_method("add_iron_scrap"):
		player.add_iron_scrap(iron_scrap_amount)
	
	# Create collection effect
	var effect_scene = load("res://scenes/DisintegrationEffect.tscn")
	var effect = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position
	effect.setup_from_sprite($Sprite2D)
	
	# Hide the chest
	$Sprite2D.visible = false
	
	# Wait for effect to finish before removing
	await get_tree().create_timer(1.0).timeout
	queue_free()

func show_reward_popup():
	# Create weapon selection popup
	var weapon_selection = preload("res://scenes/WeaponSelection.tscn").instantiate()
	
	# Get a random weapon to level up
	var weapons = get_tree().get_nodes_in_group("weapons")
	if weapons.size() > 0:
		var random_weapon = weapons[randi() % weapons.size()]
		var weapon_options = [{
			"key": random_weapon.weapon_type,
			"name": random_weapon.weapon_type.capitalize(),
			"level": random_weapon.weapon_level + 1,
			"sprite": "res://Sprites/" + random_weapon.weapon_type + ".png"
		}]
		
		weapon_selection.setup(weapon_options)
		get_tree().root.add_child(weapon_selection)
		
		# Connect the weapon selected signal
		weapon_selection.weapon_selected.connect(_on_weapon_selected)

func _on_weapon_selected(weapon_key: String):
	# Find the weapon and level it up
	var weapons = get_tree().get_nodes_in_group("weapons")
	for weapon in weapons:
		if weapon.weapon_type == weapon_key:
			weapon.weapon_level += 1
			weapon.apply_level_bonuses()
			break 
