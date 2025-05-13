extends CharacterBody2D

@export var speed := 150.0
@export var damage := 10.0
@export var attack_cooldown := 1.0
@export var max_health := 50.0

var target: Node2D
var can_attack := true
var health: float
var sprite: Sprite2D
var base_scale: Vector2
var base_rotation: float
var animation_tween: Tween

func _ready():
	health = max_health
	sprite = $Sprite2D
	base_scale = sprite.scale
	base_rotation = sprite.rotation
	
	# Start the breathing animation
	start_breathing_animation()
	
	# Register with EnemyManager
	var enemy_manager = get_node("/root/EnemyManager")
	if enemy_manager:
		enemy_manager.register_enemy(self)

func start_breathing_animation():
	# Create a repeating animation
	animation_tween = create_tween()
	animation_tween.set_loops()  # Make it loop forever
	
	# Randomize the animation parameters slightly for each enemy
	var scale_variation = randf_range(0.05, 0.15)  # 5-15% scale variation
	var rotation_variation = randf_range(0.15, 0.25)  # 5-15 degrees rotation
	var animation_duration = randf_range(0.5, 1.5)  # Slightly random duration
	speed -= (animation_duration * 30) # Increases the speed of the enemy if the rotation is faster
	# Scale up and rotate
	animation_tween.tween_property(sprite, "scale", base_scale * (1 + scale_variation), animation_duration/2)
	animation_tween.parallel().tween_property(sprite, "rotation", base_rotation + rotation_variation, animation_duration/2)
	
	# Scale down and rotate back to opposite
	animation_tween.tween_property(sprite, "scale", base_scale * (1 - scale_variation), animation_duration/2)
	animation_tween.parallel().tween_property(sprite, "rotation", base_rotation - rotation_variation, animation_duration/2)

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

func take_damage(amount: float, is_crit: bool = false):
	health -= amount
	show_floating_damage(amount, is_crit)
	if health <= 0:
		die()

func show_floating_damage(amount: float, is_crit: bool = false):
	var damage_number_scene = preload("res://scenes/FloatingDamageNumber.tscn")
	var damage_number = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(damage_number)
	var head_position = global_position + Vector2(0, -40)
	damage_number.is_crit = is_crit
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
