extends Node3D

var crystals = 0
var unit_counter = 0

func _ready():
	$Nav/HQ.unit_manager = $Units

# displays the amount of crystals, fps and units
func _process(delta):
	$Counter.set_text("kristalle: " + str(Global.crystals)+ "   " + "FPS: " + str(Engine.get_frames_per_second()) + "   " + "Unitzahl: "+ str(unit_counter))

# attempts to remove a deleted unit from the camera's selection
func _on_units_delete_selection(unit):
	if $Camera.selection.has(unit):
		$Camera.selection.erase(unit) # removes the unit if it is in the camera's current selection
