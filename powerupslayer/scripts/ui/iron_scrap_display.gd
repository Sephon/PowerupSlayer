extends Control

@onready var label = $Panel/HBoxContainer/Label
@onready var panel = $Panel

func _ready():
	# Hide initially
	#panel.modulate.a = 0
	
	# Connect to ResourceManager signals
	var resource_manager = get_node("/root/ResourceManager")
	if resource_manager:
		resource_manager.iron_scrap_changed.connect(_on_iron_scrap_changed)
		# Initial update
		_on_iron_scrap_changed(resource_manager.get_iron_scrap())

func _on_iron_scrap_changed(new_amount: int):
	if new_amount > 0:
		# Show the display with a fade in
		var tween = create_tween()
		tween.tween_property(panel, "modulate:a", 1.0, 0.3)
		label.text = "%d/100" % new_amount
	#else:
		## Hide the display with a fade out
		#var tween = create_tween()
		#tween.tween_property(panel, "modulate:a", 0.0, 0.3) 
