extends Control

signal start_game_Dome() # signal to start blue side
signal start_game_rebels() # signal to start red side

func _ready():
	setTexts() # sets text on scene start

func setTexts():
	$Label.text = Global.getText("@interface_text_choose_faction")
	#$BlueFaction.tooltip_text = Global.getText("@name_faction_OL")
	#$RedFaction.tooltip_text = Global.getText("@name_faction_NL")
	#$BlueFaction.text = Global.getText("@interface_text_faction_red")
	#$RedFaction.text = Global.getText("@interface_text_faction_blue")

func _on_blue_faction_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	start_game_Dome.emit() # emits button for interface 

func _on_red_faction_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	start_game_rebels.emit()  # emits button for interface 

# enables the faction description when mouse hovers on button
func _on_blue_faction_mouse_entered():
	$FactionDescriptionOL.visible = true
	$FactionDescriptionOL.text = Global.getText("@name_faction_OL")
	#$FactionAnimatorOL.play("hover_OL")
func _on_blue_faction_mouse_exited():
	#$FactionAnimatorOL.play_backwards("hover_OL")
	$FactionDescriptionOL.visible = false

# enables the faction description when mouse hovers on button
func _on_red_faction_mouse_entered():
	#$FactionAnimatorNL.play("hover_NL")
	$FactionDescriptionNL.visible = true
	$FactionDescriptionNL.text = Global.getText("@name_faction_NL")
func _on_red_faction_mouse_exited():
	#$FactionAnimatorNL.play_backwards("hover_NL")
	$FactionDescriptionNL.visible = false
