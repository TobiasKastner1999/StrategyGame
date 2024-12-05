extends Control

signal start_game_Dome()
signal start_game_rebels()







func _on_blue_faction_pressed():
	start_game_Dome.emit()


func _on_red_faction_pressed():
	start_game_rebels.emit()
