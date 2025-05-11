extends Node

# Global references
var enemy_manager: Node

func _ready():
	# Initialize EnemyManager
	enemy_manager = Node.new()
	enemy_manager.name = "EnemyManager"
	add_child(enemy_manager)
	
	# Set up input map
	setup_input_map()

func setup_input_map():
	# Movement actions
	if not InputMap.has_action("move_right"):
		InputMap.add_action("move_right")
		var event = InputEventKey.new()
		event.keycode = KEY_D
		InputMap.action_add_event("move_right", event)
	
	if not InputMap.has_action("move_left"):
		InputMap.add_action("move_left")
		var event = InputEventKey.new()
		event.keycode = KEY_A
		InputMap.action_add_event("move_left", event)
	
	if not InputMap.has_action("move_up"):
		InputMap.add_action("move_up")
		var event = InputEventKey.new()
		event.keycode = KEY_W
		InputMap.action_add_event("move_up", event)
	
	if not InputMap.has_action("move_down"):
		InputMap.add_action("move_down")
		var event = InputEventKey.new()
		event.keycode = KEY_S
		InputMap.action_add_event("move_down", event) 
