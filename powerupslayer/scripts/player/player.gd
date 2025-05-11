extends CharacterBody2D

@export var speed := 300.0
@export var max_health := 100.0

var health: float
var controls: Node
var weapon_slots: Array[Node] = []
var current_weapon: Node

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
	current_weapon = bullet_weapon

func _physics_process(delta):
	# Movement
	velocity = controls.move_direction * speed
	move_and_slide()
	
	# Weapon firing
	if current_weapon:
		var enemy_manager = get_node("/root/EnemyManager")
		if enemy_manager:
			var target = enemy_manager.get_closest_to(global_position)
			if target:
				current_weapon.fire(target)

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()  # Basic death handling 
