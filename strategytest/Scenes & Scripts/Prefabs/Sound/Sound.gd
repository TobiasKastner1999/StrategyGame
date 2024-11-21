extends Control



@onready var sound_streamer = $SoundStreamer
@onready var music_streamer = $MusicStreamer



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func play_sound(sound):
	$".".add_child(sound_streamer)
	var loaded_sound = load(sound)
	sound_streamer.stream = loaded_sound
	sound_streamer.play()
	await sound_streamer.finished
	sound_streamer.queue_free()
	
func play_music(music):
	var loaded_music = load(music)
	music_streamer.stream = loaded_music
	music_streamer.play()
