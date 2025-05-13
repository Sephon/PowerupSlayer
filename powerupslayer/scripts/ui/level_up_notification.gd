extends Node2D

@onready var label = $Label

func _ready():
	# Start the animation sequence
	play_animation()

func play_animation():
	# Initial state
	scale = Vector2.ONE
	rotation = 0
	modulate.a = 1.0
	
	# Create the animation sequence
	var tween = create_tween()
	
	# First phase: stay visible for 0.3 seconds
	tween.tween_interval(1)
	
	# Second phase: scale up, rotate, and fade out
	tween.tween_property(self, "scale", Vector2(4.5, 4.5), 2.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "rotation", TAU * 2, 1.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 1.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# When animation is done, remove the notification
	tween.tween_callback(queue_free) 
