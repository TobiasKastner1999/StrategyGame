extends NavigationRegion3D

var camera_positions = [Vector3(0.0, 0.0, 175.0), Vector3(0.0, 0.0, -225.0)]
#var cursor = load()
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
	$Options.visible = true
	$Interface/FactionSelection.visible = false
	$Interface/UIFrame.visible = true
	$Interface/BuildingButton.visible = true
	$Interface/HousingButton.visible = true
	$MiniMap.visible = true
	$Counter.visible = true
	$Interface/ResourceTab.visible = true
	
	Global.player_faction = faction # sets the player's global faction to the faction they chose
	
	# sets up the AI controllers
	$FactionBlueController.setUp()
	$FactionRedController.setUp()
	$Camera.global_position = camera_positions[faction] # warps the camera to the chosen HQ's location
	$Camera.position.y = 60
	#if Global.player_faction == 1:
		#$Camera/Camera.rotation.y = 110
	for hq in get_tree().get_nodes_in_group("HQ"):
		if hq.getFaction() == faction:
			$Interface/Placer.hq_zone = hq.getArea() # locks the building placers to the platform of the player's chosen faction
			$Interface.hq = hq


# accesses a clicked building's interface menu
func _on_building_menu(building):
	$Interface/SelectedPanel.activatePanel(building)


func _on_timer_timeout():
	$HQBlue.process_mode = Node.PROCESS_MODE_INHERIT # activates the blue hq
	$HQRed.process_mode = Node.PROCESS_MODE_INHERIT # activates the red hq

# mouse cursor on hovering above certain objects

func _on_language_changed():
	$Options.setTexts()
	$Interface.setTexts()
	$Interface/FactionSelection.setTexts()
	$Interface/EndScreen.setTexts()
	$Interface/SelectedPanel.updateTexts()
	$Interface/SelectedPanel.updateSelectedInterface()
