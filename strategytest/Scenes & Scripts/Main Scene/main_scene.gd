extends NavigationRegion3D

var camera_positions = [Vector3(0.0, 0.0, 175.0), Vector3(0.0, 0.0, -225.0)]

func _ready():
	get_tree().paused = true

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

func _on_interface_start_game(faction):
	get_tree().paused = false
	$Interface/StartScreen.visible = false
	$Interface/UIFrame.visible = true
	$Interface/BuildingButton.visible = true
	$MiniMap.visible = true
	$Counter.visible = true
	
	Global.player_faction = faction
	$FactionBlueController.setUp()
	$FactionRedController.setUp()
	$Camera.global_position = camera_positions[faction]
	for hq in get_tree().get_nodes_in_group("HQ"):
		if hq.getFaction() == faction:
			$Interface/Placer.hq_zone = hq.getArea()
