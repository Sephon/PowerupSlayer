class_name WeaponBase
extends Node

@export var cooldown := 1.0
@export var damage := 10.0
@export var projectile_scene: PackedScene
@export var fire_rate := 1.0
@export var speed := 10.0
@export var rotation_speed := 2.0  # For fireball-type weapons
@export var orbit_radius := 100.0  # For fireball-type weapons
@export var crit_chance := 0.015  # 1.5% base crit chance
@export var crit_damage_multiplier := 2.0  # 200% base crit damage

var can_fire := true

func fire(target: Node2D) -> void:
	if not can_fire:
		return
	
	_spawn_projectile(target)
	can_fire = false
	await get_tree().create_timer(cooldown).timeout
	can_fire = true

func _spawn_projectile(target: Node2D) -> void:
	if not projectile_scene:
		return
	
	var projectile = projectile_scene.instantiate()
	projectile.global_position = get_parent().global_position
	
	# Calculate damage with random variation and crit
	var final_damage = damage
	var is_crit = randf() < crit_chance
	
	# Add random variation (-10% to +10%)
	var variation = randf_range(0.9, 1.1)
	final_damage *= variation
	
	# Apply crit if it occurs
	if is_crit:
		final_damage *= crit_damage_multiplier
	
	projectile.damage = final_damage
	projectile.is_crit = is_crit
	get_tree().root.add_child(projectile)
	
	# Set projectile direction
	var direction = (target.global_position - projectile.global_position).normalized()
	projectile.velocity = direction * projectile.speed

func apply_weapon_bonuses(level: int) -> void:
	# Apply standard bonuses
	damage *= 1.1
	fire_rate *= 1.1
	speed *= 1.1
	cooldown /= 1.1  # Reduce cooldown by 10%
	
	# Increase crit chance and damage slightly with level
	crit_chance *= 1.05  # 5% increase per level
	crit_damage_multiplier *= 1.05  # 5% increase per level
