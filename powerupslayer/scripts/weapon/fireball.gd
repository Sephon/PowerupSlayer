extends WeaponBase

var active_fireballs: Array[Node] = []
var max_fireballs := 1
var fireball_scene: PackedScene

func _ready():
	cooldown = 0.0  # No cooldown needed for this weapon
	damage = 20.0
	
	# Debug scene loading
	fireball_scene = load("res://scenes/fireball.tscn")

	# Verify the scene has the correct script
	var test_instance = fireball_scene.instantiate()
	test_instance.queue_free()
	
	fire_rate = 1.0
	speed = 10.0
	rotation_speed = .75
	orbit_radius = 150.0

func _process(_delta):
	# Clean up any destroyed fireballs
	active_fireballs = active_fireballs.filter(func(fb): return is_instance_valid(fb))

func fire(_target: Node2D) -> void:
	# Spawn new fireballs if we have room
	while active_fireballs.size() < max_fireballs:
		_spawn_fireball()

func _spawn_fireball() -> void:
	var fireball = fireball_scene.instantiate()	
	var player = get_parent()
		
	fireball.player = player
	fireball.damage = damage
	fireball.rotation_speed = rotation_speed
	fireball.orbit_radius = orbit_radius
	
	# Set initial angle based on number of fireballs
	var angle_offset = TAU / max_fireballs
	fireball.current_angle = active_fireballs.size() * angle_offset
	
	# Add the fireball as a child of the player
	player.add_child(fireball)
	active_fireballs.append(fireball)

# Override the base weapon's apply_weapon_bonuses to handle fireball-specific properties
func apply_weapon_bonuses(level: int) -> void:
	# Apply standard bonuses
	super.apply_weapon_bonuses(level)
	
	# Apply fireball-specific bonuses
	rotation_speed *= 1.1  # Increase rotation speed
	orbit_radius *= 1.1    # Increase orbit radius
	damage *= 1.1
	
	# Update existing fireballs with new properties
	for fireball in active_fireballs:
		if is_instance_valid(fireball):
			fireball.rotation_speed = rotation_speed
			fireball.orbit_radius = orbit_radius 
			fireball.damage *= 1.1
