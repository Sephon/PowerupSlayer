extends Area2D

var damage := 20.0
var rotation_speed := 1.0  # Rotations per second
var orbit_radius := 50.0  # Distance from player
var current_angle := 0.0
var player: Node2D

func _init():
	print("Fireball _init called")

func _enter_tree():
	print("Fireball _enter_tree called")
	print("Fireball scene tree path: ", get_path())
	print("Fireball parent: ", get_parent().name if get_parent() else "No parent")

func _ready():
	print("Fireball _ready called")
	
	# Enable collision with bodies
	collision_layer = 2  # Set to layer 2
	collision_mask = 1   # Collide with layer 1 (where enemies and player are)
	
	# Connect signals
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		print("Connected body_entered signal")
	
	# Debug print collision settings
	print("Fireball collision layer: ", collision_layer)
	print("Fireball collision mask: ", collision_mask)
	print("Fireball position: ", global_position)
	print("Fireball player reference: ", player != null)
	
	# Make sure we're visible
	modulate = Color(1, 1, 1, 1)  # Ensure full opacity
	visible = true
	print("Fireball visibility set to: ", visible)

func _process(_delta):
	if Engine.get_frames_drawn() % 60 == 0:
		print("Fireball _process running")
		print("Fireball position: ", global_position)
		print("Fireball visible: ", is_visible_in_tree())
		print("Fireball parent: ", get_parent().name if get_parent() else "No parent")

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
	print("Fireball hit something: ", body.name)
	if body.has_method("take_damage") and body.get_actor_name() != "PLAYER":
		print("Fireball damaging: ", body.name)
		body.take_damage(damage) 
