extends Node2D

@export var spawn_radius := 2500.0
@export var max_enemies := 150
@export var spawn_interval := .5
@export var super_enemy_chance := 0.01  # 1% chance
@export var super_enemy_timeout := 300.0  # 5 minutes in seconds

var enemy_scene: PackedScene
var spawn_queue: Array[Vector2] = []
var can_spawn := true
var last_super_enemy_time := -super_enemy_timeout  # Initialize to allow immediate spawn

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
	
	# Check for super enemy spawn
	var current_time = Time.get_ticks_msec() / 1000.0  # Convert to seconds
	var rand = randf()
	if rand < super_enemy_chance and (current_time - last_super_enemy_time) >= super_enemy_timeout:
		# Make it a super enemy
		enemy.is_super_enemy = true
		enemy.size_factor = randf_range(3.0, 5.0)  # 300% to 500% size
		last_super_enemy_time = current_time
	
	get_tree().root.add_child(enemy)
	
	can_spawn = false
	await get_tree().create_timer(spawn_interval).timeout
	spawn_interval -= (spawn_interval / 1000)
	can_spawn = true

func get_enemy_count() -> int:
	return get_tree().get_nodes_in_group("enemies").size() 
