extends Control




@onready var sound_streamer = $SoundStreamer
@onready var music_streamer = $MusicStreamer
var temp = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func play_sound(sound):
	var new_streamer = load("res://Scenes & Scripts/Prefabs/Sound/streamer.tscn").instantiate()
	$".".add_child(new_streamer)
	var loaded_sound = load(sound)
	new_streamer.stream = loaded_sound
	new_streamer.play()
	await new_streamer.finished
	new_streamer.queue_free()
	
func play_music(music):
	var new_streamer = load("res://Scenes & Scripts/Prefabs/Sound/streamer.tscn").instantiate()
	temp = new_streamer
	$".".add_child(new_streamer)
	var loaded_music = load(music)
	new_streamer.stream = loaded_music
	new_streamer.play()
	new_streamer
	await new_streamer.finished
	play_music(music)

func stop_music_loop():
	if temp != null:
		await temp.finished
		temp.queue_free()

func cease_music():
	if temp != null:
		temp.queue_free()
