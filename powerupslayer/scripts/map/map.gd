extends Node2D

const CHUNK_SIZE = 32
const TILE_SIZE = 64
const MARGIN = 32
const WORLD_SIZE = 512

var tilemap: TileMap
var loaded_chunks: Dictionary = {}
var rng = RandomNumberGenerator.new()

func _ready():
	# Initialize tilemap
	tilemap = TileMap.new()
	add_child(tilemap)
	
	# Load tileset
	var tileset = TileSet.new()
	var texture = load("res://Tilesheet/medieval_tilesheet.png")
	var atlas_source = TileSetAtlasSource.new()
	atlas_source.texture = texture
	atlas_source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	atlas_source.margins = Vector2i(MARGIN, MARGIN)
	atlas_source.separation = Vector2i(MARGIN, MARGIN)
	
	# Add ground tiles (assuming first 4 tiles are ground variants)
	for i in range(4):
		atlas_source.create_tile(Vector2i(i, 0))
	
	tileset.add_source(atlas_source)
	tilemap.tile_set = tileset
	
	# Generate initial chunks around origin
	update_chunks(Vector2i.ZERO)

func update_chunks(camera_chunk: Vector2i):
	# Unload chunks outside view radius
	var chunks_to_remove = []
	for chunk_pos in loaded_chunks:
		if (chunk_pos - camera_chunk).length() > 1:
			chunks_to_remove.append(chunk_pos)
	
	for chunk_pos in chunks_to_remove:
		var chunk = loaded_chunks[chunk_pos]
		chunk.queue_free()
		loaded_chunks.erase(chunk_pos)
	
	# Load new chunks
	for x in range(-1, 2):
		for y in range(-1, 2):
			var chunk_pos = camera_chunk + Vector2i(x, y)
			if not loaded_chunks.has(chunk_pos):
				generate_chunk(chunk_pos)

func generate_chunk(chunk_pos: Vector2i):
	var chunk = TileMap.new()
	chunk.tile_set = tilemap.tile_set
	add_child(chunk)
	loaded_chunks[chunk_pos] = chunk
	
	# Generate random ground tiles
	rng.randomize()
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var world_x = chunk_pos.x * CHUNK_SIZE + x
			var world_y = chunk_pos.y * CHUNK_SIZE + y
			
			if world_x >= 0 and world_x < WORLD_SIZE and world_y >= 0 and world_y < WORLD_SIZE:
				var tile_id = rng.randi_range(0, 3)  # Random ground tile
				chunk.set_cell(0, Vector2i(x, y), 0, Vector2i(tile_id, 0))
	
	# Position chunk
	chunk.position = Vector2(
		chunk_pos.x * CHUNK_SIZE * TILE_SIZE,
		chunk_pos.y * CHUNK_SIZE * TILE_SIZE
	)

func _process(_delta):
	# Update chunks based on camera position
	var camera = get_viewport().get_camera_2d()
	if camera:
		var camera_pos = camera.global_position
		var chunk_x = floor(camera_pos.x / (CHUNK_SIZE * TILE_SIZE))
		var chunk_y = floor(camera_pos.y / (CHUNK_SIZE * TILE_SIZE))
		update_chunks(Vector2i(chunk_x, chunk_y)) 
