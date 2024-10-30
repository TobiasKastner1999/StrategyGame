extends NavigationRegion3D

var crystals = 0
var unit_counter = 0

func _ready():
	$HQFriendly.unit_manager = $Units
	$HQEnemy.unit_manager = $Units

# displays the amount of crystals, fps and units
func _process(delta):
	$Counter.set_text("kristalle: " + str(Global.crystals)+ "   " + "FPS: " + str(Engine.get_frames_per_second()) + "   " + "Unitzahl: "+ str(unit_counter))

# attempts to remove a deleted unit from the camera's selection
func _on_units_delete_selection(unit):
	if $Camera.selection.has(unit):
		$Camera.selection.erase(unit) # removes the unit if it is in the camera's current selection

func _on_interface_rebake():
	bake_navigation_mesh()
