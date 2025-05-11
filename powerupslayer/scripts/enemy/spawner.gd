extends Node2D

@export var spawn_radius := 200.0
@export var max_enemies := 50
@export var spawn_interval := 1.0

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
	
	# Calculate spawn positions around viewport
	var positions: Array[Vector2] = [
		Vector2(camera_pos.x - view_size.x/2 - spawn_radius, camera_pos.y),  # Left
		Vector2(camera_pos.x + view_size.x/2 + spawn_radius, camera_pos.y),  # Right
		Vector2(camera_pos.x, camera_pos.y - view_size.y/2 - spawn_radius),  # Top
		Vector2(camera_pos.x, camera_pos.y + view_size.y/2 + spawn_radius)   # Bottom
	]
	
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
	can_spawn = true

func get_enemy_count() -> int:
	return get_tree().get_nodes_in_group("enemies").size() 
