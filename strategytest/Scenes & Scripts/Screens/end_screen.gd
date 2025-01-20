extends Control
var text = ""

func _ready():
	setTexts()

func setTexts():
	$Button.text = Global.getText("@interface_button_quit_game")


func setText():
	$GameOverText.text = text # sets text to given value

func setScreen(screen):
	match screen:
		0:
			$DomeFallen.visible = true
			$RebelsCrushed.visible = false
		1:
			$RebelsCrushed.visible = true
			$DomeFallen.visible = false

func _on_button_pressed(): # ends the game
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()
