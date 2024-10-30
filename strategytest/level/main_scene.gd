extends NavigationRegion3D

# assings the unit manager to the two HQ buildings at the start of the game
func _ready():
	$HQFriendly.unit_manager = $Units
	$HQEnemy.unit_manager = $Units

# displays the player's amount of crystals, as well as the current fps
func _process(delta):
	$Counter.set_text("kristalle: " + str(Global.crystals)+ "   " + "FPS: " + str(Engine.get_frames_per_second()))

# attempts to remove a deleted unit from the camera's selection
func _on_units_delete_selection(unit):
	if $Camera.selection.has(unit):
		$Camera.selection.erase(unit) # removes the unit if it is in the camera's current selection

# rebakes the navmesh
func _on_interface_rebake():
	bake_navigation_mesh()
