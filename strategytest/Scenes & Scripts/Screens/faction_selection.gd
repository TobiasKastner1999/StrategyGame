extends Control

signal start_game_Dome() # signal to start blue side
signal start_game_rebels() # signal to start red side







func _on_blue_faction_pressed():
	start_game_Dome.emit() # emits button for interface 


func _on_red_faction_pressed():
	start_game_rebels.emit()  # emits button for interface 
