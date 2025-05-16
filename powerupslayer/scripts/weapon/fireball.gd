extends WeaponBase

var active_fireballs: Array[Node] = []
var max_fireballs := 1
var fireball_scene: PackedScene
var base_rotation_speed: float
var base_orbit_radius: float

func _ready():
	weapon_type = "fireball"
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
	
	# Store base stats
	base_rotation_speed = rotation_speed
	base_orbit_radius = orbit_radius
	
	super._ready()  # Call parent _ready to store base stats

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

func apply_level_bonuses() -> void:
	# Apply base weapon bonuses
	super.apply_level_bonuses()
	
	# Calculate level multiplier
	var level_multiplier = pow(1.1, weapon_level - 1)
	
	# Apply fireball-specific bonuses
	rotation_speed = base_rotation_speed * (level_multiplier * 0.5)
	#orbit_radius = base_orbit_radius * level_multiplier

	# Update max fireballs based on level
	max_fireballs = max(1, min((weapon_level / 5) + 1, 5))
	
	# Update existing fireballs with new properties
	for fireball in active_fireballs:
		if is_instance_valid(fireball):
			fireball.rotation_speed = rotation_speed
			fireball.orbit_radius = orbit_radius
			fireball.damage = damage
