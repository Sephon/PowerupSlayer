extends Area2D

var damage := 20.0
var rotation_speed := 1.0  # Rotations per second
var orbit_radius := 50.0  # Distance from player
var current_angle := 0.0
var player: Node2D
var is_crit := false
var knockback = 5

func _ready():

	# Enable collision with bodies
	collision_layer = 2  # Set to layer 2
	collision_mask = 1   # Collide with layer 1 (where enemies and player are)
	
	# Connect signals
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		print("Connected body_entered signal")
	
	# Make sure we're visible
	modulate = Color(1, 1, 1, 1)  # Ensure full opacity
	visible = true

func _physics_process(delta):
	if not player:
		print("No player reference, destroying fireball")
		queue_free()
		return
	
	# Update rotation angle
	current_angle += rotation_speed * delta * TAU  # TAU is 2*PI
	if current_angle >= TAU:
		current_angle -= TAU
	
	# Calculate new position based on angle and radius
	var offset = Vector2(
		cos(current_angle) * orbit_radius,
		sin(current_angle) * orbit_radius
	)
	global_position = player.global_position + offset

func _on_body_entered(body):
	if body.has_method("take_damage") and body.get_actor_name() != "PLAYER":
		body.take_damage(damage, is_crit, knockback) 
