extends CharacterBody2D

@export var speed := 150.0
@export var damage := 10.0
@export var attack_cooldown := 1.0
@export var max_health := 50.0

var target: Node2D
var can_attack := true
var health: float

func _ready():
	health = max_health
	# Register with EnemyManager
	var enemy_manager = get_node("/root/EnemyManager")
	if enemy_manager:
		enemy_manager.register_enemy(self)

func _physics_process(_delta):
	if not target:
		target = get_closest_player()
		return
	
	# Move towards target
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	# Attack if close enough
	if can_attack and global_position.distance_to(target.global_position) < 50:
		attack()

func get_closest_player():
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		return players[0]  # For now, just get the first player
	return null

func attack():
	if target.has_method("take_damage"):
		target.take_damage(damage)
		can_attack = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func take_damage(amount: float):
	health -= amount
	show_floating_damage(amount)
	if health <= 0:
		die()

func show_floating_damage(amount):
	var damage_number_scene = preload("res://scenes/FloatingDamageNumber.tscn")
	var damage_number = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(damage_number)
	var head_position = global_position + Vector2(0, -40)
	damage_number.show_damage(amount, head_position)

func get_actor_name():
	return "ENEMY"

func die():
	spawn_xp_powerup()
	queue_free()  # Basic death handling

func spawn_xp_powerup():
	var xp_scene = preload("res://scenes/XPPowerup.tscn")
	var xp_powerup = xp_scene.instantiate()
	xp_powerup.global_position = global_position
	get_tree().current_scene.add_child(xp_powerup)

func _exit_tree():
	# Unregister from EnemyManager
	var enemy_manager = get_node("/root/EnemyManager")
	if enemy_manager:
		enemy_manager.unregister_enemy(self) 
