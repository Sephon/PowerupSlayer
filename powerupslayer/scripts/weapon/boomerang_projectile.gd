extends Area2D

var speed := 300.0
var damage := 15.0
var velocity := Vector2.ZERO
var is_crit := false
var knockback := 50
var penetration := 2
var enemies_hit := 0
var max_distance := 550.0
var return_speed := 1.5  # Speed multiplier when returning
var current_distance := 0.0
var is_returning := false
var start_position := Vector2.ZERO

@export var rotation_speed := 720.0  # Degrees per second (adjust for speed)

func _ready():
	# Enable collision with bodies
	collision_layer = 2  # Set to layer 2
	collision_mask = 1   # Collide with layer 1 (where enemies and player are)
	
	# Connect signals
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	start_position = global_position

func _physics_process(delta):
	rotation_degrees += rotation_speed * delta

	if not is_returning:
		# Moving away from player
		position += velocity * delta
		current_distance = global_position.distance_to(start_position)
		
		# Check if we've reached max distance
		if current_distance >= max_distance:
			is_returning = true
			velocity = -velocity  # Reverse direction
	else:
		# Moving back towards player
		position += velocity * return_speed * delta
		
		# Check if we've gone past the start position
		if global_position.distance_to(start_position) > max_distance * 1.5:
			queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage") and body.get_actor_name() != "PLAYER" and body.has_method("is_damageable") and body.is_damageable() == true:
		body.take_damage(damage, is_crit, knockback)
		enemies_hit += 1
		
		# Check if we've hit max number of enemies
		if enemies_hit >= penetration:
			queue_free() 
