extends Node

signal rebake() # to rebake the navmesh when a new building is placed

var build_locations = [[Vector3(0.0, 3.9, 175.0), Vector3(-25.0, 3.9, 175.0), Vector3(25.0, 3.9, 175.0)], [Vector3(0.0, 3.9, -175.0), Vector3(-25.0, 3.9, -175.0), Vector3(25.0, 3.9, -175.0)]] # the pre-determined locations where the AI can construct its buildings
var hq  # the AI's HQ building
var enemy_hq  # the player's HQ building
var worker_storage # the AI's workers

@export var controlled_faction : int # the AI-controlled faction

@onready var unit_storage = $".."/Units # the combat units
@onready var resources = $".."/Resources # the resources

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
	if build_locations[controlled_faction].size() > 0 and Global.getResource(controlled_faction, 0) >= Global.BUILDING_COST:
		constructBuilding() # constructs a new building if the AI has enough crystals and there are construction plots left

# sets a new destination for a worker
func setWorkerDestination(worker):
	var resource_list = hq.getResources() # gets all resources that are near the HQ
	if resource_list.size() == 0:
		resource_list = resources.get_children() # if there are no resources left near the HQ, gets all resources on the map instead
	if resource_list.size() > 0:
		if (Global.getResource(controlled_faction, 0) < Global.BUILDING_COST) and (build_locations[controlled_faction].size() == 3):
			for resource in resource_list:
				if resource.getType() != 0:
					resource_list.erase(resource)
		else:
			for resource in resource_list:
				if resource.getType() == 0:
					resource_list.erase(resource)
		if resource_list.size() == 0:
			resource_list = resources.get_children()
		worker.setTargetPosition(resource_list[randi_range(0, resource_list.size() - 1)].global_position) # sends the worker to a random resource from the list

# issues new commands to a combat unit
func issueUnitCommand(unit):
	if unit.isNearBody(enemy_hq):
		unit.setAttackTarget(enemy_hq) # instructs the unit to attack the enemy HQ if it is near
	else:
		unit.setTargetPosition(enemy_hq.global_position) # otherwise instructs the unit to move towards the HQ

# builds a new building
func constructBuilding():
	var building = load("res://Scenes & Scripts/Prefabs/Structures/Production/building.tscn").instantiate() # instantiates the building
	get_parent().add_child(building)
	building.transform.origin = build_locations[controlled_faction][0] # places it at the first available location
	build_locations[controlled_faction].remove_at(0) # then removes that location from the list
	building.setFaction(controlled_faction) # assigns the building's faction
	building.accessStructure() # enables unit production from the building
	rebake.emit() # calls the re-bake the navmesh
	Global.updateResource(controlled_faction, 0, -Global.BUILDING_COST) # subtracts the required crystals from the AI's resources

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