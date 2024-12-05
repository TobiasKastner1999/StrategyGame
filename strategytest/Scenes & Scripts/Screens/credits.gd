extends Node2D


@onready var text = $RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	text.add_text("Dominik-Niklas Fuchs")
	text.newline()
	text.add_text("Tobias Kastner")
	text.newline()
	text.add_text("Jakob Keber")
	text.newline()
	text.add_text("Yunus Halavart")
	text.newline()
	text.add_text("Simon Hübsch")
	text.newline()
	text.add_text("Jürgen Siebert")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	


func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes & Scripts/Screens/start_screen.tscn")
