extends Area2D

var is_destroyed := false
var hit_sound: AudioStream

func _ready():
	# Enable collision with bodies
	collision_layer = 1  # Set to layer 1
	collision_mask = 2   # Collide with layer 2 (where projectiles are)
	
	# Load hit sound
	hit_sound = load("res://soundeffects/punch-2-37333.mp3")

func _on_body_entered(body):
	if is_destroyed:
		return
		
	if body.has_method("take_damage"):
		destroy()

func take_damage(_amount: float, _is_crit: bool = false, _knockback: float = 0.0):
	if is_destroyed:
		return
	destroy()

func destroy():
	if is_destroyed:
		return
		
	is_destroyed = true
	
	# Play hit sound using AudioPool
	var audio_pool = get_node("/root/AudioPool")
	if audio_pool:
		audio_pool.play_sound(hit_sound, -10)
	
	# Create disintegration effect
	var effect_scene = load("res://scenes/DisintegrationEffect.tscn")
	var effect = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position
	effect.setup_from_sprite($Sprite2D)
	
	# Hide the original sprite
	$Sprite2D.visible = false
	
	# Spawn medikit
	spawn_medikit()
	
	# Wait for effect to finish before removing
	await get_tree().create_timer(1.0).timeout
	queue_free()

func spawn_medikit():
	var medikit_scene = preload("res://scenes/Medikit.tscn")
	var medikit = medikit_scene.instantiate()
	medikit.global_position = global_position
	get_tree().current_scene.add_child(medikit) 