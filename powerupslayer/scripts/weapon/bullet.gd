extends WeaponBase

func _ready():
	weapon_type = "bullet"
	#cooldown = 1.0
	damage = 20.0
	projectile_scene = load("res://scenes/bullet.tscn")
	#fire_rate = 1.0 
	#speed = 10
	super._ready()  # Call parent _ready to store base stats
