extends Node2D

func _process(delta):
	if $OptionsMenu/Panel.visible == false:
		$OptionsMenu.visible = false
		$OptionsMenu/Panel.visible = true



func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes & Scripts/Main Scene/main_scene.tscn")# switch scene to main

func _on_options_pressed():
	$OptionsMenu.visible = true # makes the optionsmenu visible


func _on_quit_pressed():
	get_tree().quit()#  ends the game


func _on_credits_pressed():
	get_tree().change_scene_to_file("res://Scenes & Scripts/Screens/credits.tscn")
