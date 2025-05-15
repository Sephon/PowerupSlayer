extends Area2D

@onready var sprite = $Sprite2D
@onready var glow = $Glow
var has_been_opened = false
var original_scale: Vector2

func _ready():
	# Connect the body entered signal
	body_entered.connect(_on_body_entered)
	original_scale = sprite.scale
	
	# Start with a small scale and grow
	sprite.scale = Vector2(0.1, 0.1)
	var tween = create_tween()
	tween.tween_property(sprite, "scale", original_scale, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_timer_timeout():
	# Pulse the glow
	var tween = create_tween()
	tween.tween_property(glow, "energy", 0.8, 0.5)
	tween.tween_property(glow, "energy", 0.5, 0.5)

func _on_body_entered(body):
	if has_been_opened or not body.is_in_group("player"):
		return
		
	has_been_opened = true
	
	# Give XP to player
	if body.has_method("add_xp"):
		body.add_xp(1000)
	
	# Show reward popup
	show_reward_popup()
	
	# Animate opening
	var tween = create_tween()
	tween.tween_property(sprite, "scale", original_scale * 1.2, 0.2)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.3)
	tween.tween_property(glow, "energy", 0.0, 0.3)
	
	# Queue free after animation
	await tween.finished
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
