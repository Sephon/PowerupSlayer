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

func _ready():
	health = max_health
	controls = $Controls
	setup_weapons()
	setup_health_bar()
	setup_sprite()

func setup_sprite():
	$Sprite2D.texture = load("res://Sprites/Character_Animations.png")
	$Sprite2D.hframes = 3  # Assuming the sprite sheet has 3 frames
	$Sprite2D.vframes = 1
	$Sprite2D.frame = 0

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
	
	# Add fireball weapon
	var fireball_weapon = load("res://scripts/weapon/fireball.gd").new()
	add_child(fireball_weapon)
	weapon_slots[1] = fireball_weapon
	
	# Add lightning weapon
	var lightning_weapon = load("res://scripts/weapon/lightning.gd").new()
	add_child(lightning_weapon)
	weapon_slots[2] = lightning_weapon
	
	current_weapon = bullet_weapon
	# Initialize fireball weapon
	fireball_weapon.fire(null)

func _physics_process(delta):
	# Movement
	velocity = controls.move_direction * speed
	move_and_slide()
	
	# Handle sprite animation
	is_moving = velocity.length() > 0
	if is_moving:
		animation_timer += delta
		if animation_timer >= 0.1666:  # ~166.6ms per frame
			animation_timer = 0
			animation_frame = (animation_frame + 1) % 3
			$Sprite2D.frame = animation_frame
			
			# Flip sprite based on movement direction
			#if velocity.x < 0:
				#$Sprite2D.texture = load("res://Sprites/Character_Extended_Reverse.png")
			#elif velocity.x > 0:
				#$Sprite2D.texture = load("res://Sprites/Character_Extended.png")
	else:
		# Reset to neutral sprite when not moving
		#$Sprite2D.texture = load("res://Sprites/Char.png")
		$Sprite2D.frame = 1
		animation_timer = 0
	
	for weapon in weapon_slots:
		var enemy_manager = get_node("/root/EnemyManager")
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
	# Show game over screen
	var game_over_scene = load("res://scenes/GameOver.tscn")
	var game_over = game_over_scene.instantiate()
	get_tree().root.add_child(game_over)
	game_over.show_game_over()
	# Don't queue_free() immediately to allow the game over screen to show
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
	
	# Show level up notification
	var notification_scene = load("res://scenes/LevelUpNotification.tscn")
	var notification = notification_scene.instantiate()
	add_child(notification)
	notification.position = Vector2(0, -50)  # Position above the player
	
	# Apply level bonuses to all weapons
	for weapon in weapon_slots:
		if weapon != null:
			apply_weapon_bonuses(weapon)

func apply_weapon_bonuses(weapon: Node):
	# Apply 10% bonus for each level (including current level)
	var bonus_multiplier = pow(1.1, level - 1)
	
	# Apply bonuses to weapon properties if they exist
	if "damage" in weapon:
		weapon.damage *= 1.1
	if "fire_rate" in weapon:
		weapon.fire_rate *= 1.1
	if "speed" in weapon:
		weapon.speed *= 1.1
	if "cooldown" in weapon:
		weapon.cooldown /= 1.1  # Reduce cooldown by 10%
	if "max_fireballs" in weapon:
		weapon.max_fireballs = max(1, min(level / 5, 5))
