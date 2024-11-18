extends Node

signal rebake() # to rebake the navmesh when a new building is placed

var build_locations = [[Vector3(0.0, 3.9, 175.0), Vector3(-25.0, 3.9, 175.0), Vector3(25.0, 3.9, 175.0)], [Vector3(0.0, 3.9, -175.0), Vector3(-25.0, 3.9, -175.0), Vector3(25.0, 3.9, -175.0)]] # the pre-determined locations where the AI can construct its buildings
var housing_locations = [[Vector3(0.0, 3.9, 235.0), Vector3(10.0, 3.9, 230.0), Vector3(-10.0, 3.9, 230.0), Vector3(-20.0, 3.9, 225.0), Vector3(20.0, 3.9, 225.0)], [Vector3(0.0, 3.9, -235.0), Vector3(10.0, 3.9, -230.0), Vector3(-10.0, 3.9, -230.0), Vector3(-20.0, 3.9, -225.0), Vector3(20.0, 3.9, -225.0)]]
var hq  # the AI's HQ building
var enemy_hq  # the player's HQ building
var worker_storage # the AI's workers

@export var controlled_faction : int # the AI-controlled faction

@onready var unit_storage = $".."/Units # the combat units
@onready var resources = $".."/Resources # the resources

func _ready():
	# disables the player HQ until the timer in main scene enables the HQ after 0.1 sec
	# delay is for minimap updating
	if Global.player_faction == 0:
		$"../HQBlue".process_mode = Node.PROCESS_MODE_DISABLED
	else:
		$"../HQRed".process_mode = Node.PROCESS_MODE_DISABLED




# issues AI commands
func _physics_process(_delta):
	# checks if any workers need new instructions
	for worker in worker_storage.get_children():
		if !worker.isWorking():
			setWorkerDestination(worker) # sets a new destination for workers that don't currently have one
	
	# checks if any combat units need new instructions
	for unit in unit_storage.get_children():
		if unit.getFaction() == controlled_faction and !unit.isActive():
			issueUnitCommand(unit) # issues new commands to units that currently don't have a target
	
	# checks if a new building can be constructed
	if Global.getUnitCount(controlled_faction) >= Global.getUnitLimit(controlled_faction) and housing_locations[controlled_faction].size() > 0 and Global.getResource(controlled_faction, 0) >= Global.getConstructionCost(2):
		constructBuilding(2) # constructs a new housing if the AI needs more unit room, has enough crystals, and there are empty plots left
	elif build_locations[controlled_faction].size() > 0 and Global.getResource(controlled_faction, 0) >= Global.getConstructionCost(1):
		constructBuilding(1) # otherwise constructs a new barracks if the AI has enough crystals and there are construction plots left

# sets a new destination for a worker
func setWorkerDestination(worker):
	var resource_list = hq.getResources() # gets all resources that are near the HQ
	if resource_list.size() == 0:
		resource_list = resources.get_children() # if there are no resources left near the HQ, gets all resources on the map instead
	if resource_list.size() > 0:
		if (Global.getResource(controlled_faction, 0) < Global.getConstructionCost(1)) and (build_locations[controlled_faction].size() == 3):
			for resource in resource_list: # if the AI still needs to construct a building, and does not have enough resources to do so
				if resource.getType() != 0:
					resource_list.erase(resource) # ignores all resources for units
		else:
			for resource in resource_list:
				if resource.getType() == 0:
					resource_list.erase(resource) # otherwise, ignores all resources for buildings instead
		if resource_list.size() == 0:
			resource_list = resources.get_children() # re-generates the list if ignoring a specific type of resource would cause the list to be empty
		worker.setTargetPosition(resource_list[randi_range(0, resource_list.size() - 1)].global_position) # sends the worker to a random resource from the list

# issues new commands to a combat unit
func issueUnitCommand(unit):
	if unit.isNearBody(enemy_hq):
		unit.setAttackTarget(enemy_hq) # instructs the unit to attack the enemy HQ if it is near
	else:
		unit.setTargetPosition(enemy_hq.global_position) # otherwise instructs the unit to move towards the HQ

# builds a new building
func constructBuilding(building_type):
	var building # sets up variable for the new building
	match building_type:
		1:
			building = load("res://Scenes & Scripts/Prefabs/Structures/Production/building.tscn").instantiate() # instantiates the barracks
			building.transform.origin = build_locations[controlled_faction][0] # places it at the first available location
			build_locations[controlled_faction].remove_at(0) # then removes that location from the list
			Global.updateResource(controlled_faction, 0, -Global.getConstructionCost(1)) # subtracts the required crystals from the AI's resources
		2:
			building = load("res://Scenes & Scripts/Prefabs/Structures/Production/housing.tscn").instantiate() # instantiates the housing
			building.transform.origin = housing_locations[controlled_faction][0] # places it at the first available location
			housing_locations[controlled_faction].remove_at(0) # then removes that location from the list
			Global.updateResource(controlled_faction, 0, -Global.getConstructionCost(2)) # subtracts the required crystals from the AI's resources
	
	get_parent().add_child(building)
	building.setFaction(controlled_faction) # assigns the building's faction
	building.accessStructure() # accesses the building's interface
	rebake.emit() # calls the re-bake the navmesh
	Global.add_to_list(building.position.x, building.position.z, controlled_faction, building.get_instance_id(), null, building)
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
