extends NavigationRegion3D

var camera_positions = [Vector3(-18, 10, 20), Vector3(0.0, 0.0, -225.0)]
var enemy_hq : Node3D
@onready var unit_storage = $Units
var done = false
var enemy_triggered = false


# called at the start of the game
func _ready():
	Sound.play_music("res://Sounds/BackroundMusic_Rebells_Paschimee Studio.mp3")
	get_tree().paused = true # immediately freezes the game (except for the faction selection UI)
	# set up for enemy attack, starts after 50 seconds
	$Building.setFaction(1)
	Global.updateResource(1, 1, 2)
	

# displays the player's amount of crystals, as well as the current fps
func _process(_delta):
	$Counter.set_text("FPS: " + str(Engine.get_frames_per_second()))

	if Global.getResource(Global.player_faction, 0) < 4 and done == false:
		done = true
		$HQBlue.process_mode = Node.PROCESS_MODE_INHERIT
		$HQBlue.global_position = Global.list[1]["worker"].global_position
		$HQBlue.global_position.y += 2

# ends the game when the construction building is destroyed
	if done == true and Global.list[1]["worker"] == null:
		gameEnd(Global.player_faction)
			
	
	
func _physics_process(delta):
	for unit in unit_storage.get_children():
		if !unit.isActive() and unit.getFaction() == 1:
			issueUnitCommand(unit) 





# attempts to remove a deleted unit from the camera's selection
func _on_units_delete_selection(unit):
	if $Camera.selection.has(unit):
		$Camera.selection.erase(unit) # removes the unit if it is in the camera's current selection

# rebakes the navmesh
func _on_interface_rebake(node):
	bake_navigation_mesh()
	if node != null:
		enemy_hq = node

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
	$Interface/HousingButton.visible = false
	$MiniMap.visible = true
	$Counter.visible = true
	$Interface/ResourceTab.visible = true
	
	Global.player_faction = faction # sets the player's global faction to the faction they chose
	
	# sets up the AI controllers
	$FactionBlueController.setUp()
	$FactionRedController.setUp()
	#$Camera.global_position = camera_positions[faction] # warps the camera to the chosen HQ's location
	$Camera.position.y = 60
	for hq in get_tree().get_nodes_in_group("HQ"):
		if hq.getFaction() == faction:
			$Interface/Placer.hq_zone = hq.getArea() # locks the building placers to the platform of the player's chosen faction
			$Interface.hq = hq

# accesses a clicked building's interface menu
func _on_building_menu(building):
	$Interface/SelectedPanel.activatePanel(building)
	if !enemy_triggered:
		enemy_triggered = true
		await get_tree().create_timer(45).timeout
		$Building.process_mode = Node.PROCESS_MODE_INHERIT


func _on_timer_timeout():
	$HQBlue.process_mode = Node.PROCESS_MODE_INHERIT
	#$HQRed.process_mode = Node.PROCESS_MODE_INHERIT


func issueUnitCommand(unit):
	if unit.isNearBody(enemy_hq):
		unit.setAttackTarget(enemy_hq) # instructs the unit to attack the enemy HQ if it is near
	else:
		unit.setTargetPosition(enemy_hq.global_position) # otherwise instructs the unit to move towards the HQ

