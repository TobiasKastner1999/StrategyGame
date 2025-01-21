extends NavigationRegion3D
var unit = preload("res://Scenes & Scripts/Prefabs/Units/Combat Unit/unit.tscn") # preloads scene to avoid lagspikes
var worker = preload("res://Scenes & Scripts/Prefabs/Units/Worker/worker.tscn") # preloads scene to avoid lagspikes
var baracks = preload("res://Scenes & Scripts/Prefabs/Structures/Production/building.tscn") # preloads scene to avoid lagspikes
var housing = preload("res://Scenes & Scripts/Prefabs/Structures/Production/forge.tscn") # preloads scene to avoid lagspikes
var camera_positions = [Vector3(-155.0, 0.0, 200.0), Vector3(100.0, 0.0, -55.0)] # hq positions for the camerea to spawn at
var ui = [load("res://Assets/UI/OL_UI.png"),load("res://Assets/UI/NL_UI.png") ] # ui assets for bot factions

@onready var world_size = Vector2i($Map/Map/MapSize.mesh.size.x, $Map/Map/MapSize.mesh.size.y) # the size of the level's world environment
@onready var fog_of_war = $Interface/FogOfWar # the node handling the game's fog of war

# called at the start of the game
func _ready():
	get_tree().paused = true # immediately freezes the game (except for the faction selection UI)
	Global.cam = $CameraBody.position
# displays the player's amount of crystals, as well as the current fps
func _process(_delta):
	Global.cam = $CameraBody.position
	$Counter.set_text("FPS: " + str(Engine.get_frames_per_second()))


# adds a unit to the fog of war system
func addUnitToFog(unit_node):
	fog_of_war.addUnit(unit_node)

# attempts to remove a deleted unit from the camera's selection
func _on_units_delete_selection(unit):
	if $CameraBody/Camera.selection.has(unit):
		$CameraBody/Camera.selection.erase(unit) # removes the unit if it is in the camera's current selection
	fog_of_war.attemptRemoveUnit(unit) # also attempts to remove the unit from the fog of war system
	$HQBlue.clearUnitReferences(unit)
	$HQRed.clearUnitReferences(unit)
	$Resources.clearUnitReferences(unit)
	for prop in $Map/Props.get_children():
		prop.fowExit(unit)
	
	for building in get_tree().get_nodes_in_group("building"):
		building.clearUnitReferences(unit)

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
	$Controls.visible = true
	
	# then toggles the visibility of various UI elements
	$Options.visible = true
	
	$Interface/FactionSelection.visible = false
	$MiniMap/UIFrame.visible = true
	$Interface/BuildingButton.visible = true
	$Interface/HousingButton.visible = true
	$MiniMap.visible = true
	$Counter.visible = true
	$Interface/ResourceTab.visible = true
	
	fog_of_war.newFog(Rect2(Vector2.ZERO, world_size)) # sets up the fog of war
	Global.player_faction = faction # sets the player's global faction to the faction they chose
	
	# sets up the AI controllers
	$FactionBlueController.setUp()
	$FactionRedController.setUp()
	$CameraBody.global_position = camera_positions[faction] # warps the camera to the chosen HQ's location
	$MiniMap/UIFrame.texture = ui[faction]
	$CameraBody.position.y = 60

	if Global.player_faction == 0: # sets asseets for ui based on faction 0
		Sound.play_music("res://Sounds/BackgroundMusicVariante1.mp3",$CameraBody )
		$Interface/ResourceTab/NlUiRes.visible = false
		$Interface/BuildingButton.texture_normal = load("res://Assets/UI/OL_Kaserne_UI.png") # baracks button normal
		$Interface/BuildingButton.texture_pressed = load("res://Assets/UI/OL_Kaserne_UI_pressed.png") # barracks button pressed
		$Interface/HousingButton.texture_normal = load("res://Assets/UI/OL_Forge_UI.png") # forge button normal
		$Interface/HousingButton.texture_pressed = load("res://Assets/UI/OL_Forge_UI_pressed.png") # forge button pressed
		$Interface/ResourceTab/Icon1.texture = load("res://Assets/Models/Map/Scrap.png")
		
		
	elif Global.player_faction == 1: # sets asseets for ui based on faction 1
		Sound.play_music("res://Sounds/BackgroundMusicVariante3.mp3", $CameraBody)
		$Interface/BuildingButton.texture_normal = load("res://Assets/UI/NL_barracks_UI.png") # baracks button normal
		$Interface/BuildingButton.texture_pressed = load("res://Assets/UI/NL_barracks_UI_pressed.png") # barracks button pressed
		$Interface/HousingButton.texture_normal = load("res://Assets/UI/NL_Forge_UI.png") # forge button normal
		$Interface/HousingButton.texture_pressed = load("res://Assets/UI/NL_Forge_UI_pressed.png") # forge button pressed
		$Interface/WallButton.visible = true
		$Interface/ResourceTab/Icon1.texture = load("res://Assets/UI/zenecium.png")
		$Interface/ResourceTab/NlUiRes.visible = true

	for hq in get_tree().get_nodes_in_group("HQ"):
		if hq.getFaction() == faction:
			$Interface/Placer.hq_zone = hq.getArea() # locks the building placers to the platform of the player's chosen faction
			$Interface.hq = hq
			addUnitToFog(hq)
		else:
			hq.setGreystate(false) # makes the enemy's hq invisible

# accesses a clicked building's interface menu
func _on_building_menu(building):
	$Interface/SelectedPanel.activatePanel(building)

# activates the HQ's shortly after the game start
func _on_timer_timeout():
	$HQBlue.process_mode = Node.PROCESS_MODE_INHERIT # activates the blue hq
	$HQRed.process_mode = Node.PROCESS_MODE_INHERIT # activates the red hq
	
	$HQBlue.spawnStartingWorkers()
	$HQRed.spawnStartingWorkers()

# triggers functions when a new player unit is spawned
func _on_new_unit(unit):
	addUnitToFog(unit) # has the unit tracked by the fog of war
	unit.unit_menu.connect(_on_building_menu) # connects the unit to the inspect UI

# re-sets the interface texts when the game's language is changed
func _on_language_changed():
	$Options.setTexts()
	#$Interface.setTexts()
	$Interface/FactionSelection.setTexts()
	$Interface/EndScreen.setTexts()
	$Interface/SelectedPanel.updateTexts()
	$Interface/SelectedPanel.updateSelectedInterface()

# updates the map with a new fog of war texture
func _on_fog_of_war_fow_updated(new_texture):
	$Map/Map/Bake.get_material_override().next_pass.set_shader_parameter("mask_texture", new_texture)
	$MiniMap.setFogTexture(new_texture)

# clears the inspect interface when the camera calls a new selection
func _on_camera_clear_interface():
	$Interface/SelectedPanel.clearMultiSelection()
	$Interface/SelectedPanel.unselect()

# sets up the inspect panel's multi-selection
func _on_camera_multi_select_interface(units):
	$Interface/SelectedPanel.multiSelection(units)

# calls to clear the selection when the player presses a construction button
func _on_placer_clear_selection():
	$CameraBody/Camera.clearSelection()
