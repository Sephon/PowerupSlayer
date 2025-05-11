extends Label

var float_distance := 80
var duration := 0.3  # seconds

func show_damage(amount, position):
	text = str(amount)
	global_position = position
	modulate = Color(1, 1, 1, 1)  # fully visible
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, duration)
	tween.tween_property(self, "position:y", position.y - float_distance, duration)
	await tween.finished
	queue_free() 
