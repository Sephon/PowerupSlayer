extends Node

func setup_game() -> Node:
	# Create root scene
	var root = Node2D.new()
	root.name = "Main"
	
	# Add map
	var map = Node2D.new()
	map.name = "Map"
	map.script = load("res://scripts/map/map.gd")
	root.add_child(map)
	
	# Add player
	var player = create_player()
	root.add_child(player)
	
	# Add spawner
	var spawner = Node2D.new()
	spawner.name = "Spawner"
	spawner.script = load("res://scripts/enemy/spawner.gd")
	root.add_child(spawner)
	
	# Add camera
	var camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	player.add_child(camera)
	
	return root

func create_player() -> Node2D:
	var player = CharacterBody2D.new()
	player.name = "Player"
	player.script = load("res://scripts/player/player.gd")
	
	# Add sprite
	var sprite = Sprite2D.new()
	sprite.texture = load("res://Sprites/Actor.png")
	sprite.centered = true
	player.add_child(sprite)
	
	# Add collision shape
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(32, 32)  # Half of sprite size
	collision.shape = shape
	player.add_child(collision)
	
	# Add controls
	var controls = Node.new()
	controls.name = "Controls"
	controls.script = load("res://scripts/player/controls.gd")
	player.add_child(controls)
	
	# Add to players group
	player.add_to_group("players")
	
	return player

func create_enemy() -> Node2D:
	var enemy = CharacterBody2D.new()
	enemy.name = "Enemy"
	enemy.script = load("res://scripts/enemy/enemy.gd")
	
	# Add sprite
	var sprite = Sprite2D.new()
	sprite.texture = load("res://Sprites/Spider.png")
	sprite.centered = true
	enemy.add_child(sprite)
	
	# Add collision shape
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(20, 20)  # Half of sprite size
	collision.shape = shape
	enemy.add_child(collision)
	
	# Add to enemies group
	enemy.add_to_group("enemies")
	
	return enemy

func create_bullet() -> Node2D:
	var bullet = Area2D.new()
	bullet.name = "Bullet"
	
	# Add sprite
	var sprite = Sprite2D.new()
	sprite.texture = load("res://Sprites/bullet.png")  # You'll need to create this
	sprite.centered = true
	bullet.add_child(sprite)
	
	# Add collision shape
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 4
	collision.shape = shape
	bullet.add_child(collision)
	
	# Add script
	var script = GDScript.new()
	script.source_code = """
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
"""
	script.reload()
	bullet.script = script
	
	# Add screen notifier
	var notifier = VisibleOnScreenNotifier2D.new()
	bullet.add_child(notifier)
	
	# Connect signals
	bullet.body_entered.connect(bullet._on_body_entered)
	notifier.screen_exited.connect(bullet._on_visible_on_screen_notifier_2d_screen_exited)
	
	return bullet

func _ready():
	# Create and save scenes
	var main_scene = setup_game()
	var enemy_scene = create_enemy()
	var bullet_scene = create_bullet()
	
	# Save scenes
	var packed_main = PackedScene.new()
	packed_main.pack(main_scene)
	ResourceSaver.save(packed_main, "res://scenes/main.tscn")
	
	var packed_enemy = PackedScene.new()
	packed_enemy.pack(enemy_scene)
	ResourceSaver.save(packed_enemy, "res://scenes/enemy.tscn")
	
	var packed_bullet = PackedScene.new()
	packed_bullet.pack(bullet_scene)
	ResourceSaver.save(packed_bullet, "res://scenes/bullet.tscn")
	
	# Set main scene
	get_tree().change_scene_to_packed(packed_main) 
