extends Area2D

var speed := 400.0
var damage := 20.0
var velocity := Vector2.ZERO

func _physics_process(delta):
	position += velocity * delta

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
