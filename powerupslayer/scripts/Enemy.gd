extends CharacterBody2D

@export var speed = 100.0
@export var health = 100.0
@export var damage = 10.0
@export var attack_cooldown = 1.0
@export var attack_range = 200.0

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var attack_timer = $AttackTimer
@onready var collision_shape = $CollisionShape2D
@onready var detection_area = $DetectionArea

var is_dead = false
var player = null

func _ready():
	attack_timer.wait_time = attack_cooldown
	attack_timer.start()

func _physics_process(delta):
	if is_dead:
		return
		
	if player:
		var direction = (player.global_position - global_position).normalized()
		var distance = global_position.distance_to(player.global_position)
		
		if distance > attack_range:
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO
		
		move_and_slide()
		
		# Update sprite direction
		if direction.x != 0:
			sprite.flip_h = direction.x < 0

func take_damage(amount):
	if is_dead:
		return
		
	health -= amount
	if health <= 0:
		die()

func die():
	if is_dead:
		return
		
	is_dead = true
	
	# Immediately remove from groups and disable all interactions
	remove_from_group("enemies")
	collision_shape.set_deferred("disabled", true)
	detection_area.set_deferred("monitoring", false)
	detection_area.set_deferred("monitorable", false)
	
	# Stop all timers and processes
	attack_timer.stop()
	set_physics_process(false)
	
	# Create disintegration effect
	var effect = preload("res://scenes/DisintegrationEffect.tscn").instantiate()
	effect.global_position = global_position
	get_tree().current_scene.add_child(effect)
	effect.setup_from_sprite(sprite)
	
	# Hide the sprite and disable all other nodes
	sprite.visible = false
	player = null
	
	# Queue free immediately - the effect will handle its own lifetime
	queue_free()

func _on_attack_timer_timeout():
	if is_dead or not player:
		return
		
	var distance = global_position.distance_to(player.global_position)
	if distance <= attack_range:
		player.take_damage(damage)

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_detection_area_body_exited(body):
	if body == player:
		player = null 
