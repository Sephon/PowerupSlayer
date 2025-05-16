extends Area2D

var speed := 400.0
var damage := 20.0
var velocity := Vector2.ZERO
var is_crit := false
var knockback = 100
var gunshot_sound: AudioStream

func _ready():
	# Enable collision with bodies
	collision_layer = 2  # Set to layer 2
	collision_mask = 1   # Collide with layer 1 (where enemies and player are)
	
	# Load and play sound effect using AudioPool
	gunshot_sound = load("res://soundeffects/heathers-gunshot-effect2.mp3")
	var audio_pool = get_node("/root/AudioPool")
	if audio_pool:
		audio_pool.play_sound(gunshot_sound, -25)

func _physics_process(delta):
	position += velocity * delta

func _on_body_entered(body):
	if body.has_method("take_damage") and body.get_actor_name() != "PLAYER" and body.has_method("is_damageable") and body.is_damageable() == true:
		body.take_damage(damage, is_crit, knockback)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
