extends Control


var music_slider_counter = 6 # slidercounter to visualize the music settings
var sound_slider_counter = 6 # slidercounter to visualize the sound settings
var language = 0 # languagecounter that indicates the current language selected

func _ready():
	checkMusic() # updates the visual sliders of music settings
	checkSound()


func _process(delta):
	checkFlag() # perma updates the current flag of the language icon
	if Input.is_action_just_pressed("escape") and $".".visible == true: # activates when visible ans escape pressed
		if $Panel.visible == false:
			$Panel.visible = true # when menu is hidden unhide it
			get_tree().paused = true # pause the game
		else:
			$Panel.visible = false # hides the menu when already open
			get_tree().paused = false # unpauses the game


func _on_continue_buttons_pressed():
	$Panel.visible = false # hides the menu when continued
	get_tree().paused = false # unpauses the game when button is used


func _on_quit_buttons_pressed():
	get_tree().paused = false # upause the game so that the startscreen isnt frozen
	get_tree().change_scene_to_file("res://Scenes & Scripts/Screens/start_screen.tscn") # changes scene to startscreen



func _on_menu_button_pressed():
	if $Panel.visible == false:
		$Panel.visible = true # when menu is hidden unhide it
		get_tree().paused = true # pause the game
	else:
		$Panel.visible = false # hides the menu when already open
		get_tree().paused = false # unpauses the game



func _on_music_plus_button_pressed():
	if music_slider_counter <= 10: # limits the slider
		music_slider_counter += 1 # increases the slider counter that hide/unhide the sliders
		Sound.music_volume += 10
	checkMusic() # updates the visual sliders of music settings

func _on_music_minus_button_pressed():
	if music_slider_counter >= 0: # limits the slider
		music_slider_counter -= 1 # decreases the slider counter that hide/unhide the sliders
		Sound.music_volume -= 10
	checkMusic() # updates the visual sliders of music settings

func checkMusic(): # function to update the sliders on the menu
	var button_container = $Panel/MusicContainer # gets the slider container
	for i in range(button_container.get_child_count()): # iterates through the container
		var button = button_container.get_child(i) # gets the current iterated child
		if i > music_slider_counter: # checks which sliders are withing range of the slidercounter
			button.visible = true # unhides the sliders within range
		else:
			button.visible = false # hides the sliders outside range

func _on_sound_minus_button_pressed():
	if sound_slider_counter <= 10: # limits the slider
		sound_slider_counter += 1 # increases the slider counter that hide/unhide the sliders
		Sound.sound_volume += 10
	checkSound() # updates the visual sliders of music settings

func _on_sound_plus_button_pressed():
	if sound_slider_counter <= 10: # limits the slider
		sound_slider_counter -= 1 # increases the slider counter that hide/unhide the sliders
		Sound.sound_volume += 10
	checkSound() # updates the visual sliders of music settings


func checkSound(): # function to update the sliders on the menu
	var button_container = $Panel/SoundContainer # gets the slider container
	for i in range(button_container.get_child_count()): # iterates through the container
		var button = button_container.get_child(i) # gets the current iterated child
		if i > sound_slider_counter: # checks which sliders are withing range of the slidercounter
			button.visible = true # unhides the sliders within range
		else:
			button.visible = false # hides the sliders outside range





func checkFlag(): # updates the flag icon in language selection
	if language < 0: 
		language = 0 # lowerlimit for the flagcounter 
	if language > 1:
		language = 1 # upperlimit for the flagcounter
	if language == 0: # sets the default 0 to english
		$Panel/LanguageSelection/FlagSlot.texture = load("res://Assets/UI/british flag.png")
	elif language == 1: # sets the value 1 to german
		$Panel/LanguageSelection/FlagSlot.texture = load("res://Assets/UI/german flag.png")



func _on_language_left_pressed():
	$Panel/VBoxContainer.visible = true # open the drop down for languages

# sets the language to german
func _on_german_flag_pressed():
	language = 1 
	$Panel/VBoxContainer.visible = false

# sets the language to english
func _on_british_flag_pressed():
	language = 0
	$Panel/VBoxContainer.visible = false




