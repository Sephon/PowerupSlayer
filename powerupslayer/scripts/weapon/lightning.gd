extends WeaponBase

func _ready():
	cooldown = 2.5  # Fires every 2.5 seconds
	damage = 40.0   # High damage to compensate for slow fire rate
	projectile_scene = load("res://scenes/lightning.tscn")
	fire_rate = 0.4  # 0.4 shots per second
	speed = 800.0    # Very fast projectile speed

func _spawn_projectile(target: Node2D) -> void:
	if not projectile_scene:
		return
	if target == null:
		return
	
	var projectile = projectile_scene.instantiate()
	projectile.global_position = get_parent().global_position
	projectile.target_pos = target.global_position
	
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
	print("fireing ligtning")
