extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$RichTextLabel.add_text("Dominik-Niklas Fuchs")
	$RichTextLabel.add_text("Tobias Kastner")
	$RichTextLabel.add_text("Jakob Keber")
	$RichTextLabel.add_text("Yunus Halavart")
	$RichTextLabel.add_text("Simon Hübsch")
	$RichTextLabel.add_text("Jürgen Siebert")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
