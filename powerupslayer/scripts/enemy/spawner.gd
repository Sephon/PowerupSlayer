extends Node2D

@export var spawn_radius := 2500.0
@export var max_enemies := 150
@export var spawn_interval := .5

var enemy_scene: PackedScene
var spawn_queue: Array[Vector2] = []
var can_spawn := true

func _ready():
	enemy_scene = load("res://scenes/enemy.tscn")
	update_spawn_positions()

func _process(_delta):
	if can_spawn and get_enemy_count() < max_enemies:
		spawn_enemy()

func update_spawn_positions():
	var viewport = get_viewport()
	var camera = viewport.get_camera_2d()
	if not camera:
		return
	
	var view_size = viewport.get_visible_rect().size
	var camera_pos = camera.global_position
	
	# Calculate spawn positions around viewport with randomization
	var positions: Array[Vector2] = []
	var num_positions = 8  # Number of spawn points to generate
	
	for i in range(num_positions):
		# Get random angle
		var angle = randf() * TAU
		
		# Calculate position with some randomness in distance
		var distance = spawn_radius + randf_range(-100, 100)
		var pos = Vector2(
			camera_pos.x + cos(angle) * distance,
			camera_pos.y + sin(angle) * distance
		)
		
		# Ensure position is outside viewport
		var view_rect = Rect2(
			camera_pos.x - view_size.x/2,
			camera_pos.y - view_size.y/2,
			view_size.x,
			view_size.y
		)
		
		# If position is inside viewport, push it out
		if view_rect.has_point(pos):
			var direction = (pos - camera_pos).normalized()
			pos = camera_pos + direction * (spawn_radius + 100)
		
		positions.append(pos)
	
	spawn_queue = positions

func spawn_enemy():
	if spawn_queue.is_empty():
		update_spawn_positions()
		return
	
	var spawn_pos = spawn_queue.pop_front()
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_pos
	get_tree().root.add_child(enemy)
	
	can_spawn = false
	await get_tree().create_timer(spawn_interval).timeout
	spawn_interval -= (spawn_interval / 1000)
	can_spawn = true

func get_enemy_count() -> int:
	return get_tree().get_nodes_in_group("enemies").size() 
