extends Node

signal rebake()

var time_scale = 0
var build_locations = [Vector3(0.0, 3.9, -175.0), Vector3(-25.0, 3.9, -175.0), Vector3(25.0, 3.9, -175.0)]
@onready var hq = $".."/HQEnemy
@onready var enemy_hq = $".."/HQFriendly
@onready var worker_storage = $".."/HQEnemy/Workers
@onready var unit_storage = $".."/Units
@onready var resources = $".."/Resources

func _physics_process(delta):
	time_scale += 0.016
	
	for worker in worker_storage.get_children():
		if !worker.isWorking():
			setWorkerDestination(worker)
	
	for unit in unit_storage.get_children():
		if unit.getFaction() == 1 and !unit.isActive():
			issueUnitCommand(unit)
	
	if build_locations.size() > 0 and Global.enemy_crystals >= Global.BUILDING_COST:
		constructBuilding()

func setWorkerDestination(worker):
	var destination
	var resource_list = hq.getResources()
	if resource_list.size() == 0:
		resource_list = resources.get_children()
	if resource_list.size() > 0:
		worker.setTargetPosition(resource_list[randi_range(0, resource_list.size() - 1)].global_position)

func issueUnitCommand(unit):
	if unit.isNearBody(enemy_hq):
		unit.setAttackTarget(enemy_hq)
	else:
		unit.setTargetPosition(enemy_hq.global_position)

func constructBuilding():
	var building = load("res://buildings/building.tscn").instantiate()
	get_parent().add_child(building)
	building.transform.origin = build_locations[0]
	build_locations.remove_at(0)
	building.setFaction(1)
	building.accessStructure()
	rebake.emit()
	Global.enemy_crystals -= Global.BUILDING_COST
