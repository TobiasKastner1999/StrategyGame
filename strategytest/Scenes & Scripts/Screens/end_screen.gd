extends Control
var text = ""

func _ready():
	setTexts()

func setTexts():
	$Button.text = Global.getText("@interface_button_quit_game")

func setText():
	$GameOverText.text = text # sets text to given value

func _on_button_pressed(): # ends the game
	get_tree().quit()
