extends Node

var enemies: Array = []

func register_enemy(enemy: Node):
	enemies.append(enemy)

func unregister_enemy(enemy: Node):
	enemies.erase(enemy)

func get_closest_to(pos: Vector2) -> Node:
	var closest = null
	var min_dist = INF
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist = pos.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = enemy
	return closest
