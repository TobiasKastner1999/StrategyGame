extends Node3D

var crystals = 0
var unit_counter = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.set_text("kristalle: " + str(crystals)+ "   " + "FPS: " + str(Engine.get_frames_per_second()) + "   " + "Unitzahl: "+ str(unit_counter))


