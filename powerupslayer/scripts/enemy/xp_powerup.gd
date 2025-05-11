extends Area2D

@export var suck_distance := 100
@export var suck_speed := 400
@export var xp_amount := 10

var player = null
var is_sucking_in = false

func _process(delta):
	if not player:
		player = get_tree().get_nodes_in_group("players")[0] if get_tree().get_nodes_in_group("players").size() > 0 else null
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist < suck_distance:
			is_sucking_in = true
		if is_sucking_in:
			var direction = (player.global_position - global_position).normalized()
			global_position += direction * suck_speed * delta
			if dist < 20:
				player.add_xp(xp_amount)
				queue_free() 
