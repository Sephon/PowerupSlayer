extends Label

var float_distance := 20  # Increased to 100 pixels
var duration := 0.5  # seconds for floating animation
var wait_before_floating_up = 0.2
var is_crit := false

func show_damage(amount, position):
	text = str(int(amount))
	global_position = position
	modulate = Color(1, 1, 1, 1)  # fully visible
	
	# Set initial scale
	var default_scale = Vector2(1.5, 1.5)
	
	# Create pop-up effect
	var tween = create_tween()
	
	# Pop-up animation
	if is_crit:
		# Crit styling
		modulate = Color(1, 0.2, 0.2)  # Red color for crits
		scale = default_scale * 3  # Start at 300% size
		tween.tween_property(self, "scale", default_scale * 2, 0.1)  # Scale down to 200%
		tween.tween_property(self, "scale", default_scale, 0.1)  # Scale down to normal
	else:
		# Normal hit styling
		scale = default_scale + Vector2(0.5,0.5)  # Start at 150% size
		tween.tween_property(self, "scale", default_scale, 0.1)  # Scale down to normal
	
	# Wait for 0.5 seconds before starting the float animation
	await get_tree().create_timer(wait_before_floating_up).timeout
	
	# Create new tween for floating animation
	tween = create_tween()
	tween.set_parallel(true)  # Run both animations in parallel
	tween.tween_property(self, "modulate:a", 0, duration)  # Fade out
	tween.tween_property(self, "position:y", position.y - float_distance, duration)  # Float up
	
	await tween.finished
	queue_free() 
