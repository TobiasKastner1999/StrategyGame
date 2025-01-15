extends Control




@onready var sound_streamer = $SoundStreamer # gets the streamernode
@onready var music_streamer = $MusicStreamer # gets the streamernode
var temp = null # temporary save streamer
var sound_volume = -30
var music_volume = -30
var walk_sounds = [load("res://Sounds/Walk_Ashfolk.mp3"), load("res://Sounds/Walk_NewLights_Heavy.mp3"),load("res://Sounds/Walk_NewLights_Light.mp3")]

func under_Attack():
	if $AttackSound.playing == false:
		$AttackSound.play()

func play_sound(sound, node):
	var new_streamer = load("res://Scenes & Scripts/Prefabs/Sound/streamer.tscn").instantiate() # loades the streamer
	node.add_child(new_streamer) # creates a new streamer
	var loaded_sound = load(sound)
	new_streamer.stream = loaded_sound # sets the sound to given value
	new_streamer.play() # starts the stream
	await new_streamer.finished # wait for the sound to end
	new_streamer.queue_free() # deletes the streamer
	
func play_music(music,node):
	var new_streamer = load("res://Scenes & Scripts/Prefabs/Sound/streamer_all_music.tscn").instantiate() # loades the streamer
	temp = new_streamer

	node.add_child(new_streamer) # creates a new streamer
	
	var loaded_music = load(music)
	new_streamer.stream = loaded_music # sets the sound to given value
	#new_streamer.volume = music_volume
	new_streamer.play() # starts the stream
	await new_streamer.finished  # wait for the sound to end
	play_music(music, node) # then uses itself to create loop

func play_sound_all(sound, node):
	var new_streamer = load("res://Scenes & Scripts/Prefabs/Sound/streamer_all.tscn").instantiate() # loades the streamer
	node.add_child(new_streamer) # creates a new streamer
	var loaded_sound = load(sound)
	new_streamer.stream = loaded_sound # sets the sound to given value
	new_streamer.play() # starts the stream
	await new_streamer.finished # wait for the sound to end
	new_streamer.queue_free() # deletes the streamer


func play_walk(sound, node):
	var new_streamer = load("res://Scenes & Scripts/Prefabs/Sound/streamer.tscn").instantiate() # loades the streamer
	node.add_child(new_streamer) # creates a new streamer
	#new_streamer.volume = music_volume
	var loaded_walk = load(sound)
	new_streamer.stream = loaded_walk # sets the sound to given value
	new_streamer.play() # starts the stream
	await new_streamer.finished  # wait for the sound to end
	play_music(sound, node) # then uses itself to create loop

func end_walk():
	if temp != null:
		temp.queue_free() #deletes the streamer

func stop_music_loop(): # function to end the loop from previous function when music is finished
	if temp != null: 
		await temp.finished # waits for the loop to finish
		temp.queue_free() # deletes the streamer

func cease_music(): # functions to stop music instantly 
	if temp != null:
		temp.queue_free() #deletes the streamer
