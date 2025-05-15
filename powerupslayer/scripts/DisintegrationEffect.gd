extends Node2D

@onready var particles: GPUParticles2D = $Particles

func _ready():
	# Start emitting particles
	particles.emitting = true
	
	# Queue free after particles are done
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	queue_free()

func sample_colors_from_sprite(sprite: Sprite2D) -> Array[Color]:
	var colors: Array[Color] = []
	var texture = sprite.texture
	
	# Get the image data
	var image = texture.get_image()
	
	# Sample colors from different points in the sprite
	var points = [
		Vector2(0.25, 0.25),  # Top-left quarter
		Vector2(0.75, 0.25),  # Top-right quarter
		Vector2(0.25, 0.75),  # Bottom-left quarter
		Vector2(0.75, 0.75),  # Bottom-right quarter
		Vector2(0.5, 0.5),    # Center
	]
	
	for point in points:
		var pixel_pos = Vector2(
			int(point.x * image.get_width()),
			int(point.y * image.get_height())
		)
		var color = image.get_pixel(pixel_pos.x, pixel_pos.y)
		if color.a > 0.1:  # Only add non-transparent colors
			colors.append(color)
	
	# If no colors were sampled (transparent sprite), use white
	if colors.is_empty():
		colors.append(Color(1, 1, 1, 1))
	
	return colors

func setup_from_sprite(sprite: Sprite2D):
	# Create a tiny square texture for particles
	var image = Image.create(2, 2, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 1))
	var particle_texture = ImageTexture.create_from_image(image)
	
	# Sample colors from the sprite
	var colors = sample_colors_from_sprite(sprite)
	
	# Create a new particle material
	var material = ParticleProcessMaterial.new()
	
	# Set up the material properties
	material.particle_flag_disable_z = true
	material.direction = Vector3(0, 0, 0)  # Random direction
	material.spread = 360.0  # Full spread
	material.gravity = Vector3(0, 0, 0)
	
	# More randomized velocity
	material.initial_velocity_min = 150.0
	material.initial_velocity_max = 300.0
	material.angular_velocity_min = -2.0
	material.angular_velocity_max = 2.0
	
	# Smaller particles
	material.scale_min = 0.5
	material.scale_max = 1.0
	
	# Create a color ramp that uses the sampled colors
	var gradient = Gradient.new()
	var num_points = 4
	for i in range(num_points):
		var t = float(i) / (num_points - 1)
		var color = colors[randi() % colors.size()]
		gradient.add_point(t * 0.3, color)  # First 30% of lifetime
	gradient.add_point(1.0, Color(1, 1, 1, 0))  # Fade to transparent
	material.color_ramp = gradient
	
	# Set the texture and material
	particles.texture = particle_texture
	particles.process_material = material
	
	# Set the emission box to match the sprite's size
	var sprite_size = Vector2(sprite.texture.get_width(), sprite.texture.get_height())
	material.emission_box_extents = Vector3(sprite_size.x/2.0, sprite_size.y/2.0, 0)
	
	# More particles for better effect
	var sprite_area = sprite_size.x * sprite_size.y
	particles.amount = min(200, max(50, int(sprite_area / 25)))  # Increased particle count
	
	# Set particle properties
	particles.lifetime = 0.8  # Shorter lifetime
	particles.explosiveness = 0.95  # More explosive
	particles.randomness = 0.4  # More random
	particles.one_shot = true
	particles.fixed_fps = 0
	particles.fract_delta = true
	particles.interpolate = true
