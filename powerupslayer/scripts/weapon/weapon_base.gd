class_name WeaponBase
extends Node

@export var cooldown := 1.0
@export var damage := 50.0
@export var projectile_scene: PackedScene
@export var fire_rate := 1.0
@export var speed := 10.0
@export var knockback = 1
@export var rotation_speed := 2.0  # For fireball-type weapons
@export var orbit_radius := 100.0  # For fireball-type weapons
@export var crit_chance := 0.015  # 1.5% base crit chance
@export var crit_damage_multiplier := 2.0  # 200% base crit damage

var can_fire := true
var weapon_level := 1
var weapon_type: String = "base"

# Base stats that will be used for level calculations
var base_damage: float
var base_cooldown: float
var base_fire_rate: float
var base_speed: float
var base_crit_chance: float
var base_crit_damage: float

func _ready():
	# Store base stats
	base_damage = damage
	base_cooldown = cooldown
	base_fire_rate = fire_rate
	base_speed = speed
	base_crit_chance = crit_chance
	base_crit_damage = crit_damage_multiplier

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
	if target == null:
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

func apply_level_bonuses() -> void:
	# Calculate level multiplier (10% increase per level)
	var level_multiplier = pow(1.1, weapon_level - 1)
	
	# Apply bonuses based on base stats
	damage = base_damage * level_multiplier
	fire_rate = base_fire_rate * level_multiplier
	speed = base_speed * level_multiplier
	cooldown = base_cooldown / level_multiplier  # Reduce cooldown by 10% per level
	
	# Increase crit chance and damage slightly with level
	crit_chance = base_crit_chance * pow(1.05, weapon_level - 1)  # 5% increase per level
	crit_damage_multiplier = base_crit_damage * pow(1.05, weapon_level - 1)  # 5% increase per level
