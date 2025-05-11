extends Node

func _ready():
	# Create a simple bullet sprite
	var image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 0, 1))  # Yellow bullet
	
	# Save the image
	image.save_png("res://Sprites/bullet.png")
	
	# Queue free after saving
	queue_free() 
