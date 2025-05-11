class_name WeaponBase
extends Node

@export var cooldown := 1.0
@export var damage := 10.0
@export var projectile_scene: PackedScene
@export var fire_rate := 1.0
@export var speed := 10.0
@export var rotation_speed := 2.0  # For fireball-type weapons
@export var orbit_radius := 100.0  # For fireball-type weapons

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
	projectile.damage = damage
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
