extends WeaponBase

var boomerang_scene: PackedScene
var base_penetration: int = 2
var penetration: int = 2

func _ready():
	weapon_type = "boomerang"
	cooldown = 1.0
	damage = 15.0
	boomerang_scene = load("res://scenes/boomerang.tscn")
	fire_rate = 1.0
	speed = 300.0
	penetration = base_penetration
	
	super._ready()  # Call parent _ready to store base stats

func fire(target: Node2D) -> void:
	if not can_fire:
		return
	
	_spawn_boomerang(target)
	can_fire = false
	await get_tree().create_timer(cooldown).timeout
	can_fire = true

func _spawn_boomerang(target: Node2D) -> void:
	if not boomerang_scene:
		return
	if target == null:
		return
		
	var boomerang = boomerang_scene.instantiate()
	boomerang.global_position = get_parent().global_position
	
	# Calculate damage with random variation and crit
	var final_damage = damage
	var is_crit = randf() < crit_chance
	
	# Add random variation (-10% to +10%)
	var variation = randf_range(0.9, 1.1)
	final_damage *= variation
	
	# Apply crit if it occurs
	if is_crit:
		final_damage *= crit_damage_multiplier
	
	boomerang.damage = final_damage
	boomerang.is_crit = is_crit
	boomerang.penetration = penetration
	get_tree().root.add_child(boomerang)
	
	# Set boomerang direction
	var direction = (target.global_position - boomerang.global_position).normalized()
	boomerang.velocity = direction * speed

func apply_level_bonuses() -> void:
	# Apply base weapon bonuses
	super.apply_level_bonuses()
	
	# Increase penetration every 5 levels
	penetration = base_penetration + (weapon_level - 1) / 5 