extends Area2D

func _on_body_entered(body):
	if body.has_method("take_damage") and body.get_actor_name() != "PLAYER" and body.has_method("is_damageable") and body.is_damageable() == true:
		body.take_damage(damage, is_crit)
		queue_free() 
