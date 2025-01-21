extends Node

signal navmesh_rebake()

const MAX_CONSTRUCTION = 3

var controller : Node3D
var controlled_faction : int
var construction_queue = []
var constructed_buildings = []
var construction_locations = [[0, [Vector3(-105.0, -3.2, 105.0), Vector3(-90.0, -3.2, 145.0), Vector3(-60.0, -3.2, 115.0)], [Vector3(-130.0, -4.0, 140.0), Vector3(-140.0, -4.0, 100.0), Vector3(-60.0, -4.0, 140.0)], 3], \
							  [0, [Vector3(110.0, -2.1, -145.0), Vector3(160.0, -2.1, -110.0), Vector3(100.0, -2.1, -185.0)], [Vector3(182.0, 0.0, -120.0), Vector3(200.0, 0.0, -110.0), Vector3(200.0, 0.0, -130.0)], [Vector3(179.29, -1.1, -88.52), Vector3(122.03, -1.1, -98.5), Vector3(69.673, -1.1, -191.89)] ] ]
var wall_rotations = [Vector3(0.0, -99.6, 0.0), Vector3(0.0, -136.9, 0.0), Vector3(0.0, 154.3, 0.0)]
var unit_types = []
var type_index = 0

func runBehaviour():
	if canConstruct():
		constructNext()
	updateConstructionQueue()

func canConstruct():
	if construction_queue.size() > 0:
		var next_construct = construction_queue[0]
		if Global.getResource(controlled_faction, 0) >= Global.getConstructionCost(next_construct):
			if construction_locations[controlled_faction][next_construct].size() > 0:
				return true
	return false

func constructNext():
	var construct = construction_queue[0]
	var main = controller.get_parent()
	var building
	construction_queue.remove_at(0)
	
	match construct:
		1:
			building = load("res://Scenes & Scripts/Prefabs/Structures/Production/building.tscn").instantiate()
			building.setProductionType(int(unit_types[type_index]))
			if type_index < (unit_types.size() - 1):
				type_index += 1
			else:
				type_index = 0
		2:
			building = load("res://Scenes & Scripts/Prefabs/Structures/Production/forge.tscn").instantiate()
		3:
			building= load("res://Scenes & Scripts/Prefabs/Structures/Defense/wall.tscn").instantiate()
			building.rotation = wall_rotations[0]
			wall_rotations.remove_at(0)
	
	building.transform.origin = construction_locations[controlled_faction][construct][0]
	construction_locations[controlled_faction][construct].remove_at(0)
	main.add_child(building)
	Global.updateResource(controlled_faction, 0, -Global.getConstructionCost(construct))
	building.setFaction(controlled_faction) # assigns the building's faction
	building.visible = false
	navmesh_rebake.emit() # calls the re-bake the navmesh
	Global.add_to_list(building.position.x, building.position.z, controlled_faction, building.get_instance_id(), null, building)
	constructed_buildings.append(construct)

func updateConstructionQueue():
	var constructed_numbers = getBuildingNumbers(constructed_buildings)
	var queued_numbers = getBuildingNumbers(construction_queue)

	match controlled_faction:
		0:
			for i in [1, 2]:
				if (constructed_numbers[i] + queued_numbers[i]) < MAX_CONSTRUCTION:
					construction_queue.append(i)
		
		1:
			for i in [1, 2, 3]:
				if (constructed_numbers[i] + queued_numbers[i]) < MAX_CONSTRUCTION:
					construction_queue.append(i)

func getBuildingNumbers(list):
	var numbers = [0, 0, 0, 0]
	for building in list:
		numbers[building] += 1
	return numbers

func setUpConstructionQueue():
	construction_queue.append(2)
	construction_queue.append(1)

func setControlled(node):
	controller = node
	controlled_faction = controller.getFaction()
	
	setUpConstructionQueue()
	
	for unit in Global.unit_dict.keys():
		if !(unit.begins_with("worker")) and Global.unit_dict[unit]["faction"] == controlled_faction:
			unit_types.append(unit)
