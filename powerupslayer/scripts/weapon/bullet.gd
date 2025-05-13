extends WeaponBase

func _ready():
	cooldown = 1.0
	damage = 20.0
	projectile_scene = load("res://scenes/bullet.tscn")
	fire_rate = 1.0 
	speed = 10
