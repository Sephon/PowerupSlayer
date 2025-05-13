extends CharacterBody2D

@export var speed := 300.0
@export var max_health := 100.0

var health: float
var controls: Node
var weapon_slots: Array[Node] = []
var current_weapon: Node
var xp: int = 0
var level: int = 1
var base_xp_requirement: int = 100
var xp_requirement: int = 100

func _ready():
	health = max_health
	controls = $Controls
	setup_weapons()

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
	
	# Weapon firing
	if current_weapon:
		var enemy_manager = get_node("/root/EnemyManager")
		if enemy_manager:
			var target = enemy_manager.get_closest_to(global_position)
			#if target:
				#current_weapon.fire(target)
	
	# Keep fireball weapon active
	var fireball_weapon = weapon_slots[1]
	if fireball_weapon:
		fireball_weapon.fire(null)
	
	# Keep lightning weapon active
	var lightning_weapon = weapon_slots[2]
	if lightning_weapon:
		var enemy_manager = get_node("/root/EnemyManager")
		if enemy_manager:
			var target = enemy_manager.get_closest_to(global_position)
			if target:
				lightning_weapon.fire(target)

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		die()

func get_actor_name():
	return "PLAYER"

func die():
	queue_free()  # Basic death handling 

func add_xp(amount: int):
	xp += amount
	print("XP: ", xp)
	check_level_up()

func check_level_up():
	while xp >= xp_requirement:
		level_up()

func level_up():
	level += 1
	xp -= xp_requirement
	xp_requirement = int(base_xp_requirement * pow(1.1, level - 1))
	print("Level up! Now level ", level)
	print("Next level requires ", xp_requirement, " XP")
	
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
