extends Control




@onready var sound_streamer = $SoundStreamer # gets the streamernode
@onready var music_streamer = $MusicStreamer # gets the streamernode
var temp = null # temporary save streamer
var sound_volume = 0
var music_volume = 0





func play_sound(sound):
	var new_streamer = load("res://Scenes & Scripts/Prefabs/Sound/streamer.tscn").instantiate() # loades the streamer
	$".".add_child(new_streamer) # creates a new streamer
	var loaded_sound = load(sound)
	new_streamer.stream = loaded_sound # sets the sound to given value
	new_streamer.play() # starts the stream
	await new_streamer.finished # wait for the sound to end
	new_streamer.queue_free() # deletes the streamer
	
func play_music(music):
	var new_streamer = load("res://Scenes & Scripts/Prefabs/Sound/streamer.tscn").instantiate() # loades the streamer
	temp = new_streamer
	$".".add_child(new_streamer) # creates a new streamer
	new_streamer.volume = music_volume
	var loaded_music = load(music)
	new_streamer.stream = loaded_music # sets the sound to given value
	new_streamer.play() # starts the stream
	await new_streamer.finished  # wait for the sound to end
	play_music(music) # then uses itself to create loop

func stop_music_loop(): # function to end the loop from previous function when music is finished
	if temp != null: 
		await temp.finished # waits for the loop to finish
		temp.queue_free() # deletes the streamer

func cease_music(): # functions to stop music instantly 
	if temp != null:
		temp.queue_free() #deletes the streamer
