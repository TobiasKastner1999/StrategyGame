extends Control

signal start_game_Dome() # signal to start blue side
signal start_game_rebels() # signal to start red side

func _ready():
	setTexts()

func setTexts():
	$Label.text = Global.getText("@interface_text_choose_faction")
	$BlueFaction.text = Global.getText("@interface_text_faction_blue")
	$RedFaction.text = Global.getText("@interface_text_faction_red")

func _on_blue_faction_pressed():
	start_game_Dome.emit() # emits button for interface 

func _on_red_faction_pressed():
	start_game_rebels.emit()  # emits button for interface 
