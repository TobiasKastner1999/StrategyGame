extends NavigationRegion3D

var camera_positions = [Vector3(0.0, 0.0, 175.0), Vector3(0.0, 0.0, -225.0)]

# called at the start of the game
func _ready():
	get_tree().paused = true # immediately freezes the game (except for the faction selection UI)

# displays the player's amount of crystals, as well as the current fps
func _process(_delta):
	$Counter.set_text("Faction 0 Resources: " + str(Global.faction_zero_resources) + " Faction 1 Resources: " + str(Global.faction_one_resources) + "   " + "FPS: " + str(Engine.get_frames_per_second()))

# attempts to remove a deleted unit from the camera's selection
func _on_units_delete_selection(unit):
	if $Camera.selection.has(unit):
		$Camera.selection.erase(unit) # removes the unit if it is in the camera's current selection

# rebakes the navmesh
func _on_interface_rebake():
	bake_navigation_mesh()

# calls for the game to end once either hq is destroyed
func _on_hq_destruction(faction):
	gameEnd(faction)

# called at the end of the game
func gameEnd(faction):
	$MiniMap.visible = false # disables the minimap
	$Interface.gameEnd(faction) # calls additional game end functions on the UI
	get_tree().paused = true # then freezes the rest of the game

# once the player chooses a faction at the start of the game
func _on_interface_start_game(faction):
	get_tree().paused = false # ends the game's freeze state
	
	# then toggles the visibility of various UI elements
	$Interface/StartScreen.visible = false
	$Interface/UIFrame.visible = true
	$Interface/BuildingButton.visible = true
	$MiniMap.visible = true
	$Counter.visible = true
	
	Global.player_faction = faction # sets the player's global faction to the faction they chose
	
	# sets up the AI controllers
	$FactionBlueController.setUp()
	$FactionRedController.setUp()
	$Camera.global_position = camera_positions[faction] # warps the camera to the chosen HQ's location
	for hq in get_tree().get_nodes_in_group("HQ"):
		if hq.getFaction() == faction:
			$Interface/Placer.hq_zone = hq.getArea() # locks the building placers to the platform of the player's chosen faction

func _on_building_menu(building):
	$Interface/SelectedPanel.activatePanel(building)