extends Node

signal rebake() # to rebake the navmesh when a new building is placed

const BUILDINGS_THRESHOLD = 5

var build_locations = [[Vector3(-60.0, -6.5, 120.0), Vector3(-100.0, -6.5, 110.0)], [Vector3(100.0, -6.0, -190.0), Vector3(100.0, -6.0, -150.0)]] # the pre-determined locations where the AI can construct its buildings
var housing_locations = [[Vector3(-140.0, -6.5, 145.0), Vector3(-120.0, -6.5, 145.0), Vector3(-100.0, -6.5, 145.0)], [Vector3(200.0, -7.0, -120.0), Vector3(180.0, -7.0, -120.0), Vector3(160.0, -7.0, -125.0)]]
var hq  # the AI's HQ building
var enemy_hq  # the player's HQ building
var worker_storage # the AI's workers

@export var controlled_faction : int # the AI-controlled faction

@onready var unit_storage = $".."/Units # the combat units
@onready var resources = $".."/Resources # the resources

func _ready():
	for behaviour in get_children():
		behaviour.setControlled(self)
	
	# disables the player HQ until the timer in main scene enables the HQ after 0.1 sec
	# delay is for minimap updating
	if Global.player_faction == 0:
		$"../HQBlue".process_mode = Node.PROCESS_MODE_DISABLED
	else:
		$"../HQRed".process_mode = Node.PROCESS_MODE_DISABLED

# issues AI commands
func _physics_process(_delta):
	$ConstructionControlBehaviour.runBehaviour()
	$BuildingControlBehaviour.runBehaviour()
	$WorkerControlBehaviour.runBehaviour()
	$CombatUnitControlBehaviour.runBehaviour()
	
	# checks if any combat units need new instructions
	for unit in unit_storage.get_children():
		if unit.getFaction() == controlled_faction and !unit.isActive():
			issueUnitCommand(unit) # issues new commands to units that currently don't have a target

# called once the player has selected a faction
func setUp():
	if controlled_faction == Global.player_faction:
		queue_free() # removes the AI controller if it would control the player's faction
	findHQs() # otherwise, sets up the AI's reference points

# sets up AI's hq reference points
func findHQs():
	for node in get_tree().get_nodes_in_group("HQ"):
		if node.getFaction() == controlled_faction: # finds the HQ belonging to the AI's controlled faction
			hq = node
			worker_storage = hq.getWorkers()
		else:
			enemy_hq = node # the other hq then must belong to the enemy

func getHQ():
	return hq

func getEnemyHQ():
	return enemy_hq

func getFaction():
	return controlled_faction

func getWorkers():
	return worker_storage

func getUnits():
	var temp_units = unit_storage.get_children()
	for unit in temp_units:
		if unit.getFaction() != controlled_faction:
			temp_units.erase(unit)
	return temp_units

func getBuildings():
	var buildings_temp = get_tree().get_nodes_in_group("Building")
	for building in buildings_temp:
		if building.getFaction() != controlled_faction:
			buildings_temp.erase(building)
	buildings_temp.append(hq)
	return buildings_temp

func getResources():
	return resources

func getRequiredResource():
	if (Global.getResource(controlled_faction, 0) >= Global.getMaxResource(controlled_faction, 0)) and (Global.getResource(controlled_faction, 1) >= Global.getMaxResource(controlled_faction, 1)):
		return null
	elif Global.getResource(controlled_faction, 0) >= Global.getMaxResource(controlled_faction, 0):
		return 1
	elif Global.getResource(controlled_faction, 1) >= Global.getMaxResource(controlled_faction, 1):
		return 0
	elif getBuildings().size() < BUILDINGS_THRESHOLD:
		return 0
	elif Global.getFullUnitCount(controlled_faction) < Global.getUnitLimit(controlled_faction):
		return 1
	else:
		return 2

# issues new commands to a combat unit
func issueUnitCommand(unit):
	if unit.isNearBody(enemy_hq):
		unit.setAttackTarget(enemy_hq) # instructs the unit to attack the enemy HQ if it is near
	else:
		unit.setTargetPosition(enemy_hq.global_position) # otherwise instructs the unit to move towards the HQ

func _on_construction_control_behaviour_navmesh_rebake():
	rebake.emit()
