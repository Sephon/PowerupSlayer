extends Control

signal weapon_selected(weapon_key: String)

var weapon_options: Array = []

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func setup(options: Array):
	weapon_options = options
	create_weapon_buttons()

func create_weapon_buttons():
	var container = $WeaponContainer
	
	# Clear existing buttons
	for child in container.get_children():
		child.queue_free()
	
	# Create new buttons for each weapon
	for option in weapon_options:
		var button = create_weapon_button(option)
		container.add_child(button)

func create_weapon_button(option: Dictionary) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(200, 80)
	
	# Create container for button content
	var container = HBoxContainer.new()
	container.custom_minimum_size = Vector2(180, 60)
	button.add_child(container)
	
	# Add weapon sprite
	var sprite = TextureRect.new()
	sprite.custom_minimum_size = Vector2(50, 50)
	sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture = load(option.sprite)
	container.add_child(sprite)
	
	# Add weapon info
	var info = VBoxContainer.new()
	container.add_child(info)
	
	var name_label = Label.new()
	name_label.text = option.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	info.add_child(name_label)
	
	var level_label = Label.new()
	level_label.text = "Level: " + str(option.level)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	info.add_child(level_label)
	
	# Connect button signal
	button.pressed.connect(_on_weapon_button_pressed.bind(option.key))
	
	return button

func _on_weapon_button_pressed(weapon_key: String):
	weapon_selected.emit(weapon_key)
	queue_free()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		queue_free() 