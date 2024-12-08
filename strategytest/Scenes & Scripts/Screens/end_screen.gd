extends Control
var text = ""





func _process(delta):
	$GameOverText.text = text # sets text to given value


func _on_button_pressed(): # ends the game
	get_tree().quit()
