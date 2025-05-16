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
var is_paused: bool = false
var is_dying: bool = false
var size_factor: float  # Will store the random size factor
var knockback_velocity: Vector2 = Vector2.ZERO
var flash_tween: Tween
var hit_sound: AudioStream
var is_super_enemy: bool = false

func _ready():
	# Generate random size factor between 0.75 and 1.25 for normal enemies
	if not is_super_enemy:
		size_factor = randf_range(0.75, 1.25)
	
	# Apply quadratic scaling to health and speed
	# Larger enemies have more health but move slower
	# Smaller enemies have less health but move faster
	max_health *= clamp(size_factor * size_factor, 1.0, 100.0)  # Quadratic scaling for health
	speed /= clamp(size_factor * size_factor, 1.0, 10.0)    # Quadratic scaling for speed (inverse relationship)
	
	health = max_health
	sprite = $Sprite2D
	base_scale = sprite.scale * size_factor  # Apply size factor to base scale
	sprite.scale = base_scale  # Set initial scale
	base_rotation = sprite.rotation
	
	# Start the breathing animation
	start_breathing_animation()
	
	# Load sound effect
	hit_sound = load("res://soundeffects/punch-2-37333.mp3")
	
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
	if is_paused or is_dying:
		return
		
	if not target:
		target = get_closest_player()
		return
	
	# Handle knockback
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.2)  # Gradually reduce knockback
		if knockback_velocity.length() < 1.0:  # Stop knockback when it gets very small
			knockback_velocity = Vector2.ZERO
	else:
		# Normal movement towards target
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
	if is_paused or is_dying:
		return
		
	if target.has_method("take_damage"):
		target.take_damage(damage)
		can_attack = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func is_damageable():
	return not is_dying

func take_damage(amount: float, is_crit: bool = false, knockback: float = 0.0):
	if is_dying:
		return
		
	# Play hit sound using AudioPool
	var audio_pool = get_node("/root/AudioPool")
	if audio_pool:
		audio_pool.play_sound(hit_sound, -10)
		
	health -= amount
	show_floating_damage(amount, is_crit)
	
	# Apply knockback if any
	if knockback > 0:
		var knockback_direction = (global_position - get_closest_player().global_position).normalized()
		knockback_velocity = knockback_direction * knockback
	
	# Flash effect
	flash_damage()
	
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
	if is_dying:
		return
		
	is_dying = true
	
	# Stop all animations and movement
	if animation_tween:
		animation_tween.kill()
		$CollisionShape2D.set_deferred("disabled", true)	
	
	# Create disintegration effect
	var effect_scene = load("res://scenes/DisintegrationEffect.tscn")
	var effect = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position
	effect.setup_from_sprite(sprite)
	
	# Hide the original sprite
	sprite.visible = false
	
	# Spawn XP powerup
	spawn_xp_powerup()
	
	# If it's a super enemy, spawn a chest
	if is_super_enemy:
		spawn_chest()
	
	# Wait for effect to finish before removing the enemy
	await get_tree().create_timer(1.6).timeout
	queue_free()

func spawn_xp_powerup():
	var xp_scene = preload("res://scenes/XPPowerup.tscn")
	var xp_powerup = xp_scene.instantiate()
	xp_powerup.global_position = global_position
	get_tree().current_scene.add_child(xp_powerup)

func spawn_chest():
	var chest_scene = preload("res://scenes/Chest.tscn")
	var chest = chest_scene.instantiate()
	chest.global_position = global_position
	get_tree().current_scene.add_child(chest)

func _exit_tree():
	# Unregister from EnemyManager
	var enemy_manager = get_node("/root/EnemyManager")
	if enemy_manager:
		enemy_manager.unregister_enemy(self)

func set_paused(paused: bool):
	is_paused = paused
	if animation_tween:
		if paused:
			animation_tween.pause()
		else:
			animation_tween.play() 

func flash_damage():
	# Kill any existing flash tween
	if flash_tween:
		flash_tween.kill()
	
	# Create new flash tween
	flash_tween = create_tween()
	flash_tween.set_parallel(true)
	
	# Flash white
	flash_tween.tween_property(sprite, "modulate", Color(255, 255, 255, 1), 0.01)
	flash_tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.1).set_delay(0.01)
