extends Node

# closes the game when the player presses the quit button
func _on_button_quit_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." ) # plays the button sound
	await get_tree().create_timer(0.5).timeout # stalls for the sound to play 
	get_tree().quit() # ends the game
