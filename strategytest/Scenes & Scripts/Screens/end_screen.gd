extends Control
var text = ""

func _ready():
	setTexts()

func setTexts(): # sets the text for the quit button
	$Button.text = Global.getText("@interface_button_quit_game")
	$Menu.text = Global.getText("@interface_button_main_menu")


func setText():
	$GameOverText.text = text # sets text to given value

func setScreen(screen): # sets the correct screen based on what ending you achieved
	match screen:
		0:
			$DomeFallen.visible = true
			$RebelsCrushed.visible = false
		1:
			$RebelsCrushed.visible = true
			$DomeFallen.visible = false
		3:
			$RebelsCrushed.visible = false
			$DomeFallen.visible = false
			$OlStarved.visible = true

func _on_button_pressed(): # ends the game
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." ) # plays the button sound
	await get_tree().create_timer(0.5).timeout # stalls the scene for button sound
	get_tree().quit() # ends the game


func _on_menu_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	await get_tree().create_timer(0.5).timeout
	get_tree().paused = false # upause the game so that the startscreen isnt frozen
	Balance.reset()
	get_tree().change_scene_to_file("res://Scenes & Scripts/Screens/start_screen.tscn") # changes scene to startscreen
