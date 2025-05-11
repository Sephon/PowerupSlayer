extends CharacterBody2D

@export var speed := 150.0
@export var damage := 10.0
@export var attack_cooldown := 1.0

var target: Node2D
var can_attack := true

func _ready():
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

func _exit_tree():
	# Unregister from EnemyManager
	var enemy_manager = get_node("/root/EnemyManager")
	if enemy_manager:
		enemy_manager.unregister_enemy(self) 
