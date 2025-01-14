extends Node

# closes the game when the player presses the quit button
func _on_button_quit_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	get_tree().quit()
