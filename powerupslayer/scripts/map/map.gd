extends Node2D

const CHUNK_SIZE = 32
const TILE_SIZE = 64
const MARGIN = 32
const WORLD_SIZE = 3000  # 3000x3000 tiles
const UPDATE_COOLDOWN = 0.5  # Seconds between chunk updates

var tilemap: TileMap
var loaded_chunks: Dictionary = {}
var rng = RandomNumberGenerator.new()
var last_camera_chunk: Vector2i = Vector2i.ZERO
var update_timer: float = 0.0

func _ready():
	# Initialize tilemap
	tilemap = TileMap.new()
	add_child(tilemap)
	
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		var pos = Vector2(WORLD_SIZE * TILE_SIZE / 2, WORLD_SIZE * TILE_SIZE / 2)
		player.position = pos

	# Load tileset
	var tileset = TileSet.new()
	var texture = load("res://Tilesheet/medieval_tilesheet.png")
	var atlas_source = TileSetAtlasSource.new()
	atlas_source.texture = texture
	atlas_source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	atlas_source.margins = Vector2i(MARGIN, MARGIN)
	atlas_source.separation = Vector2i(MARGIN, MARGIN)
	
	# Add ground tiles (assuming first 4 tiles are ground variants)
	for x in range(4):
		for y in range(3):
			atlas_source.create_tile(Vector2i(x, y))
	
	tileset.add_source(atlas_source)
	tilemap.tile_set = tileset
	tilemap.tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)  # Set the tile size for the TileMap
	
	# Generate initial chunks around origin
	update_chunks(Vector2i.ZERO)

func update_chunks(camera_chunk: Vector2i):
	# Unload chunks outside view radius
	var chunks_to_remove = []
	for chunk_pos in loaded_chunks:
		if (chunk_pos - camera_chunk).length() > 5:  # Unload chunks outside 11x11 grid
			chunks_to_remove.append(chunk_pos)
	
	for chunk_pos in chunks_to_remove:
		var chunk = loaded_chunks[chunk_pos]
		chunk.queue_free()
		loaded_chunks.erase(chunk_pos)
	
	# Load new chunks to cover 300x300 tiles (10x10 chunks)
	for x in range(-5, 6):
		for y in range(-5, 6):
			var chunk_pos = wrap_chunk(camera_chunk + Vector2i(x, y))
			if not loaded_chunks.has(chunk_pos):
				generate_chunk(chunk_pos)

func wrap_chunk(chunk_pos: Vector2i) -> Vector2i:
	# Wrap chunk position for world wrapping
	return Vector2i(chunk_pos.x % (WORLD_SIZE / CHUNK_SIZE), chunk_pos.y % (WORLD_SIZE / CHUNK_SIZE))

func generate_chunk(chunk_pos: Vector2i):
	var chunk = TileMap.new()
	chunk.tile_set = tilemap.tile_set
	add_child(chunk)
	loaded_chunks[chunk_pos] = chunk
	
	# Generate random ground tiles
	rng.randomize()
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var world_x = int(chunk_pos.x) * CHUNK_SIZE + x
			var world_y = int(chunk_pos.y) * CHUNK_SIZE + y
			# Wrap world coordinates
			world_x = world_x % WORLD_SIZE
			world_y = world_y % WORLD_SIZE
			if world_x >= 0 and world_x < WORLD_SIZE and world_y >= 0 and world_y < WORLD_SIZE:
				var random_x = rng.randi_range(0, 3)  # Random ground tile
				var random_y = rng.randi_range(0,0)
				chunk.set_cell(0, Vector2i(x, y), 0, Vector2i(random_x, random_y))

	
	# Position chunk
	chunk.position = Vector2(
		int(chunk_pos.x) * CHUNK_SIZE * TILE_SIZE,
		int(chunk_pos.y) * CHUNK_SIZE * TILE_SIZE
	)	

func _process(delta):
	# Update chunks based on camera position
	var camera = get_viewport().get_camera_2d()
	if camera:
		var camera_pos = camera.global_position
		var chunk_x = int(floor(camera_pos.x / (CHUNK_SIZE * TILE_SIZE)))
		var chunk_y = int(floor(camera_pos.y / (CHUNK_SIZE * TILE_SIZE)))
		var current_chunk = Vector2i(chunk_x, chunk_y)
		
		# Only update if we've moved to a new chunk and cooldown has passed
		if current_chunk != last_camera_chunk:
			update_timer += delta
			if update_timer >= UPDATE_COOLDOWN:
				update_chunks(current_chunk)
				last_camera_chunk = current_chunk
				update_timer = 0.0
		
		wrap_player_if_needed()

func wrap_player_if_needed():
	var players = get_tree().get_nodes_in_group("players")
	for player in players:
		var pos = player.global_position
		var max_pos = WORLD_SIZE * TILE_SIZE
		var wrapped = false
		if pos.x < 0:
			pos.x += max_pos
			wrapped = true
		elif pos.x >= max_pos:
			pos.x -= max_pos
			wrapped = true
		if pos.y < 0:
			pos.y += max_pos
			wrapped = true
		elif pos.y >= max_pos:
			pos.y -= max_pos
			wrapped = true
		if wrapped:
			player.global_position = pos 
