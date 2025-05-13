extends CanvasLayer

func _ready():
	# Make sure we're on top
	layer = 100
	# Start hidden
	visible = false
	# Process input even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if not visible:
		return
		
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			get_tree().quit()
		elif event.keycode == KEY_ENTER and event.pressed:
			restart_game()

func show_game_over():
	visible = true
	get_tree().paused = true

func restart_game():
	# Unpause first
	get_tree().paused = false
	
	# Change to the main scene
	get_tree().change_scene_to_file("res://scenes/main.tscn") 
