extends NavigationRegion3D

# displays the player's amount of crystals, as well as the current fps
func _process(_delta):
	$Counter.set_text("Crystals: " + str(Global.crystals)+ "   " + "FPS: " + str(Engine.get_frames_per_second()))

# attempts to remove a deleted unit from the camera's selection
func _on_units_delete_selection(unit):
	if $Camera.selection.has(unit):
		$Camera.selection.erase(unit) # removes the unit if it is in the camera's current selection

# rebakes the navmesh
func _on_interface_rebake():
	bake_navigation_mesh()

func _on_hq_destruction(faction):
	gameEnd(faction)

func gameEnd(faction):
	$MiniMap.visible = false
	$Interface.gameEnd(faction)
	get_tree().paused = true
