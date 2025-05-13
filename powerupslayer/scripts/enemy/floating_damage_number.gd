extends Label

var float_distance := 80
var duration := 0.3  # seconds
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
		scale = default_scale * 3  # Start at 200% size
		tween.tween_property(self, "scale", default_scale * 2, 0.1)  # Scale down to 150%
		tween.tween_property(self, "scale", default_scale, 0.1)  # Scale down to normal
	else:
		# Normal hit styling
		scale = default_scale + Vector2(0.5,0.5)  # Start at 150% size
		tween.tween_property(self, "scale", default_scale, 0.1)  # Scale down to normal
	
	# Fade out and float up
	tween.tween_property(self, "modulate:a", 0, duration)
	tween.tween_property(self, "position:y", position.y - float_distance, duration)
	
	await tween.finished
	queue_free() 
