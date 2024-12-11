extends Control
var text = ""

func _ready():
	$Button.text = Global.getText($Button.text)

func setText():
	$GameOverText.text = text # sets text to given value

func _on_button_pressed(): # ends the game
	get_tree().quit()
