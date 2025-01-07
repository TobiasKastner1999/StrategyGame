extends NavigationRegion3D


var camera_positions = [Vector3(-235.0, 0.0, 265.0), Vector3(241.0, 0.0, -299.0)] # hq positions for the camerea to spawn at
var ui = [load("res://Assets/UI/NL_UI.png"),load("res://Assets/UI/OL_UI.png") ] # ui assets for bot factions

@onready var world_size = Vector2i($Map/Map/MapSize.mesh.size.x, $Map/Map/MapSize.mesh.size.y) # the size of the level's world environment
@onready var fog_of_war = $Interface/FogOfWar # the node handling the game's fog of war

#var cursor = load()

# called at the start of the game
func _ready():
	get_tree().paused = true # immediately freezes the game (except for the faction selection UI)
	
# displays the player's amount of crystals, as well as the current fps
func _process(_delta):
	$Counter.set_text("Faction 0 Resources: " + str(Global.faction_zero_resources) + " Faction 1 Resources: " + str(Global.faction_one_resources) + "   " + "FPS: " + str(Engine.get_frames_per_second()))

# adds a unit to the fog of war system
func addUnitToFog(unit_node):
	fog_of_war.addUnit(unit_node)

# attempts to remove a deleted unit from the camera's selection
func _on_units_delete_selection(unit):
	if $Camera.selection.has(unit):
		$Camera.selection.erase(unit) # removes the unit if it is in the camera's current selection
	fog_of_war.attemptRemoveUnit(unit) # also attempts to remove the unit from the fog of war system
	$HQBlue.clearUnitReferences(unit)
	$HQRed.clearUnitReferences(unit)
	$Resources.clearUnitReferences(unit)
	
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
	get_tree().paused = false # ends the game's freeze state
	# then toggles the visibility of various UI elements
	$Options.visible = true
	$Interface/FactionSelection.visible = false
	$MiniMap/UIFrame.visible = true
	$Interface/BuildingButton.visible = true
	$Interface/HousingButton.visible = true
	$Interface/UpgradeButton.visible = true
	$MiniMap.visible = true
	$Counter.visible = true
	$Interface/ResourceTab.visible = true
	
	fog_of_war.newFog(Rect2(Vector2.ZERO, world_size)) # sets up the fog of war
	Global.player_faction = faction # sets the player's global faction to the faction they chose
	
	# sets up the AI controllers
	$FactionBlueController.setUp()
	$FactionRedController.setUp()
	$Camera.global_position = camera_positions[faction] # warps the camera to the chosen HQ's location
	$MiniMap/UIFrame.texture = ui[faction]
	$Camera.position.y = 60


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

func _on_timer_timeout():
	$HQBlue.process_mode = Node.PROCESS_MODE_INHERIT # activates the blue hq
	$HQRed.process_mode = Node.PROCESS_MODE_INHERIT # activates the red hq

func _on_new_unit(unit):
	addUnitToFog(unit)
	unit.unit_menu.connect(_on_building_menu)

# re-sets the interface texts when the game's language is changed
func _on_language_changed():
	$Options.setTexts()
	$Interface.setTexts()
	$Interface/FactionSelection.setTexts()
	$Interface/EndScreen.setTexts()
	$Interface/SelectedPanel.updateTexts()
	$Interface/SelectedPanel.updateSelectedInterface()

# updates the map with a new fog of war texture
func _on_fog_of_war_fow_updated(new_texture):
	$Map/Map/Bake.get_material_override().next_pass.set_shader_parameter("mask_texture", new_texture)
	$MiniMap.setFogTexture(new_texture)

func _on_camera_clear_interface():
	$Interface/SelectedPanel.clearMultiSelection()
	$Interface/SelectedPanel.unselect()


func _on_camera_multi_select_interface(units):
	$Interface/SelectedPanel.multiSelection(units)


func _on_upgrade_button_pressed():
	Balance.upgrade1 = true

func _on_placer_clear_selection():
	$Camera.clearSelection()
