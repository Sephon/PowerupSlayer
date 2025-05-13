extends Control

@onready var level_label = $MarginContainer/VBoxContainer/LevelLabel
@onready var progress_bar = $MarginContainer/VBoxContainer/ProgressBar
@onready var xp_label = $MarginContainer/VBoxContainer/XPLabel

var player: Node

func _ready():
	# Wait for the player to be ready
	await get_tree().create_timer(0.1).timeout
	player = get_tree().get_first_node_in_group("players")
	if player:
		update_display()

func _process(_delta):
	if player:
		update_display()

func update_display():
	level_label.text = "Level: %d" % player.level
	progress_bar.max_value = player.xp_requirement
	progress_bar.value = player.xp
	xp_label.text = "%d/%d XP" % [player.xp, player.xp_requirement] 
