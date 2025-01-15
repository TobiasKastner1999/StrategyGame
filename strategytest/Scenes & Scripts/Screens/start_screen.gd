extends Node2D

var main = preload("res://Scenes & Scripts/Main Scene/main_scene.tscn")
signal video_over()

func _ready():
	setTexts() #  sets the starting language



# setter methods
func setTexts():
	$Start.text = Global.getText("@interface_button_start_game")
	$Options.text = Global.getText("@interface_button_settings")
	$Credits.text = Global.getText("@interface_button_credits")
	$Quit.text = Global.getText("@interface_button_quit_game")
	$Skip.text = Global.getText("@interface_button_skip_video")
	if Global.selected_language == "en":
		$VideoStreamPlayer.stream = load("res://Videos/Trailer-Englisch.ogv")
	elif Global.selected_language == "de":
		$VideoStreamPlayer.stream = load("res://Videos/Intro-Deutsch.ogv")



func _on_start_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$".")
	await get_tree().create_timer(0.5).timeout
	$VideoStreamPlayer.visible = true
	$VideoStreamPlayer.play()
	$Skip.visible = true
	await $VideoStreamPlayer.finished

func _on_options_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	$OptionMenu.visible = true # makes the optionsmenu visible



func _on_quit_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()#  ends the game


func _on_credits_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Scenes & Scripts/Screens/credits.tscn") # switch to the credits


func _on_option_menu_close():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	$OptionMenu.visible = false # hides the menu

func _on_language_changed():
	setTexts() # changes the text
	$OptionMenu.setTexts() # changes the text


func _on_button_pressed():
	if $VideoStreamPlayer.is_playing():
		$VideoStreamPlayer.stop()
		emit_signal("video_over")




func _on_video_over():
	get_tree().change_scene_to_file("res://Scenes & Scripts/Main Scene/main_scene.tscn")# switch scene to main
