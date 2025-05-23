extends Node

var enemies: Array = []
var is_paused: bool = false

func register_enemy(enemy: Node):
	enemies.append(enemy)

func unregister_enemy(enemy: Node):
	enemies.erase(enemy)

func get_closest_to(pos: Vector2) -> Node:
	var closest = null
	var min_dist = INF
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy.is_dying:
			continue
		var dist = pos.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = enemy
	return closest

func set_paused(paused: bool):
	is_paused = paused
	# Notify all enemies about the pause state
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has_method("set_paused"):
			enemy.set_paused(paused)
