extends Node

const POOL_SIZE := 16
var audio_players: Array[AudioStreamPlayer] = []
var current_index := 0
# Global references
var audio_pool: Node

func _ready():
	audio_pool = Node.new()
	audio_pool.name = "AudioPool"
	add_child(audio_pool)


	# Create the pool of audio players
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		add_child(player)
		audio_players.append(player)

func play_sound(sound: AudioStream, volume_db: float = 0.0) -> bool:
	# Try to find a free player
	for i in range(POOL_SIZE):
		var index = (current_index + i) % POOL_SIZE
		var player = audio_players[index]
		
		if not player.playing:
			player.stream = sound
			player.volume_db = volume_db
			player.play()
			current_index = (index + 1) % POOL_SIZE
			return true
	
	# If all players are busy, use the oldest one
	var oldest_player = audio_players[current_index]
	oldest_player.stop()
	oldest_player.stream = sound
	oldest_player.volume_db = volume_db
	oldest_player.play()
	current_index = (current_index + 1) % POOL_SIZE
	return true 
