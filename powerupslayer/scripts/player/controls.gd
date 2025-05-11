extends Node

var move_direction := Vector2.ZERO

func _process(_delta):
	# Keyboard input
	move_direction = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		move_direction.x += 1
	if Input.is_action_pressed("move_left"):
		move_direction.x -= 1
	if Input.is_action_pressed("move_down"):
		move_direction.y += 1
	if Input.is_action_pressed("move_up"):
		move_direction.y -= 1
	
	# Gamepad input
	var gamepad_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if gamepad_direction.length() > 0.1:  # Deadzone
		move_direction = gamepad_direction
	
	# Normalize diagonal movement
	if move_direction.length() > 1:
		move_direction = move_direction.normalized() 
