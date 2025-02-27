extends Node

signal navmesh_rebake() # to call a navmesh rebake upon construction

const MAX_CONSTRUCTION = 3 # the maximum number that can be constructed of any given building type

var controller : Node3D # the faction controller this node belongs to
var controlled_faction : int # the faction controlled by this node
var construction_queue = [] # the queue of which buildings are to be constructed next
var constructed_buildings = [] # the list of already constructed buildings

# the locations at which various buildings can be constructed, based on faction
var construction_locations = [[0, [Vector3(-105.0, -3.2, 105.0), Vector3(-90.0, -3.2, 145.0), Vector3(-60.0, -3.2, 115.0)], [Vector3(-130.0, -4.2, 140.0), Vector3(-140.0, -4.2, 100.0), Vector3(-50.0, -4.2, 140.0)], 3], \
							  [0, [Vector3(95.0, -3.3, -162.5), Vector3(150.0, -3.3, -115.0), Vector3(95.0, -3.3, -195.0)], [Vector3(182.0, -4.0, -125.0), Vector3(200.0, -4.0, -115.0), Vector3(200.0, -4.0, -135.0)], [Vector3(179.29, -1.1, -88.52), Vector3(122.65, -1.1, -98.5), Vector3(69.673, -1.1, -191.89)] ] ]
var wall_rotations = [Vector3(0, -95.7, 0), Vector3(0, -139.6, 0), Vector3(0, 158.6, 0)] # the rotations for constructed walls

# runs this behaviour's sub-behaviours
func runBehaviour():
	if canConstruct(): # checks if the next building in queue can be constructed
		constructNext() # if yes, that building is then constructed
	updateConstructionQueue() # updates the construction queue

# checks if the next building in the construction queue can be constructed
func canConstruct():
	if construction_queue.size() > 0:
		var next_construct = construction_queue[0] # checks if there is a building in queue at all
		if Global.getResource(controlled_faction, 0) >= Global.getConstructionCost(next_construct):
			if construction_locations[controlled_faction][next_construct].size() > 0:
				return true # returns true if the player has enough resources, and a valid building location for the queued building
	return false

# constructs the next building in queue
func constructNext():
	var construct = construction_queue[0]
	var main = controller.get_parent()
	var building
	construction_queue.remove_at(0) # removes the building from the queue
	
	# performs actions based on the building's type
	match construct:
		# constructs a new barracks
		1:
			building = load("res://Scenes & Scripts/Prefabs/Structures/Production/building.tscn").instantiate()
			match controlled_faction:
				0:
					building.setProductionType(1)
				1:
					building.setProductionType(0)
		
		# constructs a new forge
		2:
			building = load("res://Scenes & Scripts/Prefabs/Structures/Production/forge.tscn").instantiate()
		
		# constructs a new wall
		3:
			building = load("res://Scenes & Scripts/Prefabs/Structures/Defense/wall.tscn").instantiate()
			building.rotation_degrees = wall_rotations[0] # also sets the wall's rotation
			wall_rotations.remove_at(0)
	
	building.transform.origin = construction_locations[controlled_faction][construct][0] # sets the building's location
	construction_locations[controlled_faction][construct].remove_at(0)
	main.add_child(building)
	Global.updateResource(controlled_faction, 0, -Global.getConstructionCost(construct)) # removes the resource cost
	await building.setFaction(controlled_faction) # assigns the building's faction
	building.visible = false
	navmesh_rebake.emit() # calls the re-bake the navmesh
	building.destroyed.connect(get_parent().get_parent()._on_building_destroyed)
	Global.add_to_list(building.position.x, building.position.z, controlled_faction, building.get_instance_id(), null, building)
	constructed_buildings.append(construct)

# updates the building construction queue
func updateConstructionQueue():
	# grabs the numbers of constructed and queued buildings of each type
	var constructed_numbers = getBuildingNumbers(constructed_buildings)
	var queued_numbers = getBuildingNumbers(construction_queue)
	
	# queues different building types based on faction
	match controlled_faction:
		0:
			for i in [1, 2]:
				if (constructed_numbers[i] + queued_numbers[i]) < MAX_CONSTRUCTION:
					construction_queue.append(i) # queues another building of that type if their current and queued number is below the maximum
		1:
			for i in [1, 2, 3]:
				if (constructed_numbers[i] + queued_numbers[i]) < MAX_CONSTRUCTION:
					construction_queue.append(i) # queues another building of that type if their current and queued number is below the maximum

# returns the numbers of different building types in a given list
func getBuildingNumbers(list):
	var numbers = [0, 0, 0, 0]
	for building in list:
		numbers[building] += 1 # for each building in the list, increments the number of its type
	return numbers

# sets up the initial construction queue with a single forge and a single barracks
func setUpConstructionQueue():
	construction_queue.append(2)
	construction_queue.append(1)

func addBuildingPosition(pos, rot, type):
	var num_type : int
	match type:
		"building":
			num_type = 1
		"forge":
			num_type = 2
		"wall":
			num_type = 3
			wall_rotations.append(rot)
	construction_locations[controlled_faction][num_type].append(pos)
	constructed_buildings.erase(num_type)

# sets up the node
func setControlled(node):
	# sets the node's controller & controlled faction
	controller = node
	controlled_faction = controller.getFaction()
	
	setUpConstructionQueue() # sets up the initial construction queue
