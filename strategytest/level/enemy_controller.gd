extends Node

signal rebake() # to rebake the navmesh when a new building is placed

var build_locations = [Vector3(0.0, 3.9, -175.0), Vector3(-25.0, 3.9, -175.0), Vector3(25.0, 3.9, -175.0)] # the pre-determined locations where the AI can construct its buildings
@onready var hq = $".."/HQEnemy # the AI's HQ building
@onready var enemy_hq = $".."/HQFriendly # the player's HQ building
@onready var worker_storage = $".."/HQEnemy/Workers # the AI's workers
@onready var unit_storage = $".."/Units # the combat units
@onready var resources = $".."/Resources # the resources

# issues AI commands
func _physics_process(delta):
	# checks if any workers need new instructions
	for worker in worker_storage.get_children():
		if !worker.isWorking():
			setWorkerDestination(worker) # sets a new destination for workers that don't currently have one
	
	# checks if any combat units need new instructions
	for unit in unit_storage.get_children():
		if unit.getFaction() == 1 and !unit.isActive():
			issueUnitCommand(unit) # issues new commands to units that currently don't have a target
	
	# checks if a new building can be constructed
	if build_locations.size() > 0 and Global.getCrystals(1) >= Global.BUILDING_COST:
		constructBuilding() # constructs a new building if the AI has enough crystals and there are construction plots left

# sets a new destination for a worker
func setWorkerDestination(worker):
	var destination
	var resource_list = hq.getResources() # gets all resources that are near the HQ
	if resource_list.size() == 0:
		resource_list = resources.get_children() # if there are no resources left near the HQ, gets all resources on the map instead
	if resource_list.size() > 0:
		worker.setTargetPosition(resource_list[randi_range(0, resource_list.size() - 1)].global_position) # sends the worker to a random resource from the list

# issues new commands to a combat unit
func issueUnitCommand(unit):
	if unit.isNearBody(enemy_hq):
		unit.setAttackTarget(enemy_hq) # instructs the unit to attack the enemy HQ if it is near
	else:
		unit.setTargetPosition(enemy_hq.global_position) # otherwise instructs the unit to move towards the HQ

# builds a new building
func constructBuilding():
	var building = load("res://buildings/building.tscn").instantiate() # instantiates the building
	
	get_parent().add_child(building)
	building.transform.origin = build_locations[0] # places it at the first available location
	build_locations.remove_at(0) # then removes that location from the list
	building.setFaction(1) # assigns the building's faction
	building.accessStructure() # enables unit production from the building
	rebake.emit() # calls the re-bake the navmesh
	Global.addCrystals(-Global.BUILDING_COST, 1) # subtracts the required crystals from the AI's resources
