extends Node2D

func _ready():
	setTexts()

func setTexts():
	$Start.text = Global.getText("@interface_button_start_game")
	$Options.text = Global.getText("@interface_button_settings")
	$Credits.text = Global.getText("@interface_button_credits")
	$Quit.text = Global.getText("@interface_button_quit_game")

#func _process(delta):
	#if $OptionsMenu.visible == false:
		#$OptionsMenu.visible = false
		#$OptionsMenu/Panel.visible = true

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes & Scripts/Main Scene/main_scene.tscn")# switch scene to main

func _on_options_pressed():
	$OptionMenu.visible = true # makes the optionsmenu visible


func _on_quit_pressed():
	get_tree().quit()#  ends the game


func _on_credits_pressed():
	get_tree().change_scene_to_file("res://Scenes & Scripts/Screens/credits.tscn") # switch to the credits


func _on_option_menu_close():
	$OptionMenu.visible = false

func _on_language_changed():
	setTexts()
	$OptionMenu.setTexts()
