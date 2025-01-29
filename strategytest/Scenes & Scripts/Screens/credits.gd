extends Node2D


@onready var text = $RichTextLabel # Label to fill with names


 # added text to the credits
func _ready():
	$Button.text = Global.getText($Button.text)
	
	text.add_text("Producer: Dominik-Niklas Fuchs")
	text.newline()
	text.add_text("Tools Programmer: Tobias Kastner")
	text.newline()
	text.add_text("System Programmer: Jakob Keber")
	text.newline()
	text.add_text("Game Designer: Yunus Halavart")
	text.newline()
	text.add_text("Artist: Simon Hübsch")
	text.newline()
	text.add_text("Artist: Jürgen Siebert")
	text.newline()
	text.add_text("Sound and Music: Pixabay.com")
	text.newline()
	text.add_text("Publisher: HNU")

	



func _on_button_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$".") # plays button sound
	await get_tree().create_timer(0.5).timeout # delays the stream start for button sound
	get_tree().change_scene_to_file("res://Scenes & Scripts/Screens/start_screen.tscn") # change scene back to startingmenu
