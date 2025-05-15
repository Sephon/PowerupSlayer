extends Node2D

@onready var health_bar = $Health
var max_health: float
var current_health: float

func _ready():
	# Start hidden
	modulate.a = 0.0

func setup(max_hp: float):
	max_health = max_hp
	current_health = max_hp
	update_health(max_hp)

func update_health(new_health: float):
	current_health = new_health
	var health_percent = current_health / max_health
	
	# Update the health bar width
	var health_width = 38.0 * health_percent  # 38 is the full width (19 * 2)
	health_bar.size.x = health_width
	health_bar.position.x = -19.0 + (health_width / 2.0)
	
	# Show/hide based on health
	if current_health < max_health:
		# Fade in
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.2)
	else:
		# Fade out
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.2) 
