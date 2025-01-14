extends Control

signal close
signal language_changed()

var music_slider_counter = 6 # slidercounter to visualize the music settings
var sound_slider_counter = 6 # slidercounter to visualize the sound settings
var language = 0 # languagecounter that indicates the current language selected

func _ready():
	checkMusic() # updates the visual sliders of music settings
	checkSound()
	setTexts()

func setTexts():
	$MenuButton.text = Global.getText("@interface_button_pause_menu")
	$Panel/ContinueButtons.text = Global.getText("@interface_button_continue")
	$Panel/QuitButtons.text = Global.getText("@interface_button_main_menu")
	$Panel/LabelMusic.text = Global.getText("@interface_text_music_settings")
	$Panel/LabelSound.text = Global.getText("@interface_text_sound_settings")

func _process(_delta):
	checkFlag() # perma updates the current flag of the language icon
	if Input.is_action_just_pressed("escape") and $".".visible == true: # activates when visible ans escape pressed
		Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
		if $Panel.visible == false:
			$Panel.visible = true # when menu is hidden unhide it
			get_tree().paused = true # pause the game
		else:
			$Panel.visible = false # hides the menu when already open
			get_tree().paused = false # unpauses the game


func _on_continue_buttons_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	$Panel.visible = false # hides the menu when continued
	get_tree().paused = false # unpauses the game when button is used
	close.emit()

func _on_quit_buttons_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	await get_tree().create_timer(0.5).timeout
	get_tree().paused = false # upause the game so that the startscreen isnt frozen
	get_tree().change_scene_to_file("res://Scenes & Scripts/Screens/start_screen.tscn") # changes scene to startscreen



func _on_menu_button_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	if $Panel.visible == false:
		$Panel.visible = true # when menu is hidden unhide it
		get_tree().paused = true # pause the game
	else:
		$Panel.visible = false # hides the menu when already open
		get_tree().paused = false # unpauses the game



func _on_music_plus_button_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	if music_slider_counter <= 10: # limits the slider
		music_slider_counter += 1 # increases the slider counter that hide/unhide the sliders
		Sound.music_volume -= 10
	checkMusic() # updates the visual sliders of music settings

func _on_music_minus_button_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	if music_slider_counter >= 0: # limits the slider
		music_slider_counter -= 1 # decreases the slider counter that hide/unhide the sliders
		Sound.music_volume += 10
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
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	if sound_slider_counter <= 10: # limits the slider
		sound_slider_counter += 1 # increases the slider counter that hide/unhide the sliders
		Sound.sound_volume += 10
	checkSound() # updates the visual sliders of music settings

func _on_sound_plus_button_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
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
	if Global.selected_language == "en": # sets the default 0 to english
		$Panel/LanguageSelection/FlagSlot.texture = load("res://Assets/UI/british flag.png")
	elif Global.selected_language == "de": # sets the value 1 to german
		$Panel/LanguageSelection/FlagSlot.texture = load("res://Assets/UI/german flag.png")

func _on_language_left_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	$Panel/VBoxContainer.visible = true # open the drop down for languages

# sets the language to german
func _on_german_flag_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	language = 1 
	Global.selected_language = "de"
	$Panel/VBoxContainer.visible = false
	language_changed.emit()

# sets the language to english
func _on_british_flag_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	language = 0
	Global.selected_language = "en"
	$Panel/VBoxContainer.visible = false
	language_changed.emit()

func _on_close():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	if $MenuButton.visible == false:
		$Panel.visible = true
