extends Area2D

var damage := 40.0  # Higher base damage since it's slower firing
var speed := 800.0  # Very fast since it's lightning
var velocity := Vector2.ZERO
var is_crit := false
var zigzag_frequency := 15.0  # How often it changes direction
var zigzag_amplitude := 20.0  # How far it zigzags
var time := 0.0
var start_pos: Vector2
var target_pos: Vector2
var segments: Array[Vector2] = []
var max_distance := 500.0  # Maximum distance the lightning can travel
var num_layers := 7  # Number of lightning layers
var base_width := 2.0  # Width of the center line
var layer_spacing := 1.5  # Space between layers
var lifetime := 0.5  # How long the lightning stays visible
var current_scale := 1.5  # Start at 150% scale
var collision_points: Array[Vector2] = []
var has_hit := false  # Track if we've hit an enemy

func _ready():
	# Enable collision with bodies
	collision_layer = 2  # Set to layer 2
	collision_mask = 1   # Collide with layer 1 (where enemies and player are)
	start_pos = global_position
	
	# Make sure we're visible and drawing
	visible = true
	queue_redraw()
	
	# Start the fade out
	var tween = create_tween()
	tween.tween_property(self, "current_scale", 1.0, lifetime * 0.3)  # Scale down to 100%
	tween.parallel().tween_property(self, "modulate:a", 0.0, lifetime)  # Fade out
	await tween.finished
	queue_free()

func _physics_process(delta):
	time += delta
	
	# Calculate zigzag pattern
	var direction = (target_pos - start_pos).normalized()
	var perpendicular = Vector2(-direction.y, direction.x)
	var distance = min(start_pos.distance_to(target_pos), max_distance)
	var progress = min(1.0, (global_position - start_pos).length() / distance)
	
	# Create zigzag offset
	var zigzag = sin(time * zigzag_frequency) * zigzag_amplitude * (1.0 - progress)
	var offset = perpendicular * zigzag
	
	# Update position
	global_position += velocity * delta + offset
	
	# Update segments for drawing
	update_segments()
	
	# Update collision points
	update_collision_points()
	
	# Check if we've gone far enough
	if (global_position - start_pos).length() > distance:
		queue_free()

func _draw():
	# Draw the lightning bolt
	if segments.size() < 2:
		return
	
	# Calculate direction for layer offsets
	var direction = (target_pos - start_pos).normalized()
	
	# Draw multiple layers of lightning
	for layer in range(num_layers):
		var layer_offset = (layer - (num_layers - 1) / 2.0) * layer_spacing
		var layer_width = base_width * (1.0 - float(layer) / num_layers)
		var layer_alpha = 1.0 - float(layer) / num_layers
		var layer_color = Color(0.7, 0.9, 1.0, layer_alpha * modulate.a)  # Blueish color
		
		# Draw the layer
		for i in range(segments.size() - 1):
			# Convert global positions to local positions
			var start = to_local(segments[i]) * current_scale
			var end = to_local(segments[i + 1]) * current_scale
			var offset = Vector2(-direction.y, direction.x) * layer_offset
			draw_line(start + offset, end + offset, layer_color, layer_width)

func update_segments():
	segments.clear()
	var num_segments = 12  # More segments for smoother zigzag
	var direction = (target_pos - start_pos).normalized()
	var distance = min(start_pos.distance_to(target_pos), max_distance)
	
	for i in range(num_segments + 1):
		var t = float(i) / num_segments
		var pos = start_pos + direction * distance * t
		var perpendicular = Vector2(-direction.y, direction.x)
		var zigzag = sin(time * zigzag_frequency + t * 15) * zigzag_amplitude * (1.0 - t)
		pos += perpendicular * zigzag
		segments.append(pos)
	
	queue_redraw()

func update_collision_points():
	if has_hit:  # Skip collision checks if we've already hit something
		return
		
	collision_points.clear()
	
	# Create collision points along the lightning path
	for i in range(segments.size() - 1):
		var start = segments[i]
		var end = segments[i + 1]
		var direction = (end - start).normalized()
		var perpendicular = Vector2(-direction.y, direction.x)
		
		# Add points for each layer
		for layer in range(num_layers):
			var layer_offset = (layer - (num_layers - 1) / 2.0) * layer_spacing
			var offset = perpendicular * layer_offset
			collision_points.append(start + offset)
			collision_points.append(end + offset)
	
	# Check for collisions with enemies
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not enemy.has_method("take_damage"):
			continue
		
		# Check if any collision point is close enough to the enemy
		for point in collision_points:
			if point.distance_to(enemy.global_position) < 20:  # Adjust this value based on enemy size
				enemy.take_damage(damage, is_crit)
				has_hit = true  # Mark that we've hit something
				return

func _on_body_entered(body):
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		print("Lightning hit: ", body.name)  # Debug print
		body.take_damage(damage, is_crit)
		has_hit = true  # Mark that we've hit something

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free() 
