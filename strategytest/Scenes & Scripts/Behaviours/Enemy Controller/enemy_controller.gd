extends Node

signal rebake() # to rebake the navmesh when a new building is placed

const BUILDINGS_THRESHOLD = 5 # the number of buildings above which the AI will no longer prioritize building materials

var hq  # the AI's HQ building
var enemy_hq  # the player's HQ building
var worker_storage # the AI's workers

@export var controlled_faction : int # the AI-controlled faction
@onready var unit_storage = $".."/Units # the combat units
@onready var resources = $".."/Resources # the resources

# alled at the start of the game
func _ready():
	for behaviour in get_children():
		behaviour.setControlled(self) # sets up all the sub-behaviours
	
	# disables the player HQ until the timer in main scene enables the HQ after 0.1 sec
	# delay is for minimap updating
	if Global.player_faction == 0:
		$"../HQBlue".process_mode = Node.PROCESS_MODE_DISABLED
	else:
		$"../HQRed".process_mode = Node.PROCESS_MODE_DISABLED

# issues AI commands on each physics call
func _physics_process(_delta):
	$ConstructionControlBehaviour.runBehaviour()
	$BuildingControlBehaviour.runBehaviour()
	$WorkerControlBehaviour.runBehaviour()
	$CombatUnitControlBehaviour.runBehaviour()

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

# returns the controlled faction's HQ
func getHQ():
	return hq

# returns the opposing faction's HQ
func getEnemyHQ():
	return enemy_hq

# returns the controlled faction
func getFaction():
	return controlled_faction

# returns the storage node of the controlled faction's workers
func getWorkers():
	return worker_storage

# returns all units belonging to the controlled factionw
func getUnits():
	var units = unit_storage.get_children() # grabs all combat units
	var temp_units = units.duplicate()
	for unit in temp_units:
		if unit.getFaction() != controlled_faction:
			units.erase(unit) # then removes all units not of the controlled faction
	return units # returns the trimmed list

func getBuildings():
	var buildings = get_tree().get_nodes_in_group("Building") # grabs all buildings
	var buildings_temp = buildings.duplicate()
	for building in buildings_temp:
		if building.getFaction() != controlled_faction:
			buildings.erase(building) # then removes all buildings not of the controlled faction
	buildings.append(hq)
	return buildings # returns the trimmed list

# returns all resources
func getResources():
	return resources

# returns the resource currently required by the controlled faction
func getRequiredResource():
	if (Global.getResource(controlled_faction, 0) >= Global.getMaxResource(controlled_faction, 0)) and (Global.getResource(controlled_faction, 1) >= Global.getMaxResource(controlled_faction, 1)):
		return null # returns a failstate if both resources are capped
	elif Global.getResource(controlled_faction, 0) >= Global.getMaxResource(controlled_faction, 0):
		return 1 # returns resource 1 if only resource 0 is capped
	elif Global.getResource(controlled_faction, 1) >= Global.getMaxResource(controlled_faction, 1):
		return 0 # returns resource 0 if only resource 1 is capped
	elif Global.getFullUnitCount(controlled_faction) < Global.getUnitLimit(controlled_faction):
		return 1 # returns resource 1 if the controlled faction can produce more units
	elif getBuildings().size() < BUILDINGS_THRESHOLD:
		return 0 # returns resource 0 if the faction has not yet reached the building threshold
	else:
		return 2 # returns an empty state otherwise

func addBuildingPosition(pos, rot, type):
	$ConstructionControlBehaviour.addBuildingPosition(pos, rot, type)

# calls to rebake the navmesh when the construction behaviour has constructed a new building
func _on_construction_control_behaviour_navmesh_rebake():
	rebake.emit()
	if getBuildings().size() == 3:
		var redirected = 0
		for worker in worker_storage.get_children():
			worker.clearKnowledge()
			redirected += 1
			if redirected >= 2:
				return
