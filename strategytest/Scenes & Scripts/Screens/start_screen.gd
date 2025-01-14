extends Node2D

func _ready():
	setTexts() #  sets the starting language

# setter methods
func setTexts():
	$Start.text = Global.getText("@interface_button_start_game")
	$Options.text = Global.getText("@interface_button_settings")
	$Credits.text = Global.getText("@interface_button_credits")
	$Quit.text = Global.getText("@interface_button_quit_game")



func _on_start_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$".")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Scenes & Scripts/Main Scene/main_scene.tscn")# switch scene to main

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
