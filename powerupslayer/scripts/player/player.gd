extends CharacterBody2D

@export var speed := 150.0
@export var max_health := 100.0

var health: float
var controls: Node
var weapon_slots: Array[Node] = []
var current_weapon: Node
var xp: int = 0
var level: int = 1
var base_xp_requirement: int = 100
var xp_requirement: int = 100
var health_bar: Node2D
var animation_timer: float = 0.0
var animation_frame: int = 0
var is_moving: bool = false
var is_paused: bool = false
var enemy_manager: Node

# Available weapons for selection
var available_weapons = {
	"bullet": {
		"name": "Bullet",
		"scene": "res://scripts/weapon/bullet.gd",
		"sprite": "res://Sprites/weapons/bullet.png"
	},
	"fireball": {
		"name": "Fireball",
		"scene": "res://scripts/weapon/fireball.gd",
		"sprite": "res://Sprites/weapons/fireball.png"
	},
	"lightning": {
		"name": "Lightning",
		"scene": "res://scripts/weapon/lightning.gd",
		"sprite": "res://Sprites/weapons/lightning.png"
	}
}

func _ready():
	health = max_health
	controls = $Controls
	enemy_manager = get_node("/root/EnemyManager")
	setup_weapons()
	setup_health_bar()
	setup_sprite()

func setup_sprite():
	$Sprite2D.texture = load("res://Sprites/Character_Animations.png")
	$Sprite2D.hframes = 3
	$Sprite2D.vframes = 1
	$Sprite2D.frame = 1

func setup_health_bar():
	var health_bar_scene = load("res://scenes/HealthBar.tscn")
	health_bar = health_bar_scene.instantiate()
	add_child(health_bar)
	health_bar.position.y = 60  # Position below the player
	health_bar.position.x = -10
	health_bar.setup(max_health)

func setup_weapons():
	# Initialize weapon slots
	weapon_slots.resize(5)
	weapon_slots.fill(null)
	
	# Add initial bullet weapon
	var bullet_weapon = load("res://scripts/weapon/bullet.gd").new()
	add_child(bullet_weapon)
	weapon_slots[0] = bullet_weapon
	bullet_weapon.weapon_level = 1
	
	current_weapon = bullet_weapon
	bullet_weapon.fire(null)

func _physics_process(delta):
	if is_paused:
		return
		
	# Movement
	velocity = controls.move_direction * speed
	move_and_slide()
	
	# Handle sprite animation
	is_moving = velocity.length() > 0
	if is_moving:
		animation_timer += delta
		if animation_timer >= 0.1666:
			animation_timer = 0
			animation_frame = (animation_frame + 1) % 3
			$Sprite2D.frame = animation_frame
	else:
		$Sprite2D.frame = 1
		animation_timer = 0
	
	for weapon in weapon_slots:
		if enemy_manager and weapon != null:
			var target = enemy_manager.get_closest_to(global_position)
			if target:
				weapon.fire(target)

func take_damage(amount: float):
	health -= amount
	health_bar.update_health(health)
	if health <= 0:
		die()

func get_actor_name():
	return "PLAYER"

func die():
	var game_over_scene = load("res://scenes/GameOver.tscn")
	var game_over = game_over_scene.instantiate()
	get_tree().root.add_child(game_over)
	game_over.show_game_over()
	await get_tree().create_timer(0.1).timeout
	queue_free()

func add_xp(amount: int):
	xp += amount
	check_level_up()

func check_level_up():
	while xp >= xp_requirement:
		level_up()

func level_up():
	level += 1
	xp -= xp_requirement
	xp_requirement = int(base_xp_requirement * pow(1.1, level - 1))
	
	# Pause game logic
	is_paused = true
	if enemy_manager:
		enemy_manager.set_paused(true)
	
	# Show weapon selection popup
	show_weapon_selection()

func show_weapon_selection():
	var selection_scene = load("res://scenes/WeaponSelection.tscn")
	var selection = selection_scene.instantiate()
	add_child(selection)
	selection.position = Vector2(0, -50)
	
	# Get available weapons for selection
	var available_options = []
	for weapon_key in available_weapons:
		var weapon_data = available_weapons[weapon_key]
		var existing_weapon = find_weapon_by_type(weapon_key)
		
		available_options.append({
			"key": weapon_key,
			"name": weapon_data.name,
			"sprite": weapon_data.sprite,
			"level": existing_weapon.weapon_level if existing_weapon else 1
		})
	
	selection.setup(available_options)
	selection.weapon_selected.connect(_on_weapon_selected)

func find_weapon_by_type(weapon_type: String) -> Node:
	for weapon in weapon_slots:
		if weapon != null and weapon.weapon_type == weapon_type:
			return weapon
	return null

func _on_weapon_selected(weapon_key: String):
	var weapon_data = available_weapons[weapon_key]
	var existing_weapon = find_weapon_by_type(weapon_key)
	
	if existing_weapon:
		# Level up existing weapon
		existing_weapon.weapon_level += 1
		existing_weapon.apply_level_bonuses()
	else:
		# Add new weapon
		var new_weapon = load(weapon_data.scene).new()
		add_child(new_weapon)
		new_weapon.weapon_level = 1
		
		# Find first empty slot
		for i in range(weapon_slots.size()):
			if weapon_slots[i] == null:
				weapon_slots[i] = new_weapon
				break
	
	# Resume game logic
	is_paused = false
	if enemy_manager:
		enemy_manager.set_paused(false)
