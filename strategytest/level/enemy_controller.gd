extends Node

@onready var hq = $".."/HQEnemy
@onready var worker_storage = $".."/HQEnemy/Workers
@onready var unit_storage = $".."/Units
@onready var resources = $".."/Resources

func _physics_process(delta):
	for worker in worker_storage.get_children():
		if !worker.isWorking():
			setWorkerDestination(worker)

func setWorkerDestination(worker):
	var destination
	var resource_list = hq.getResources()
	if resource_list.size() == 0:
		resource_list = resources.get_children()
	if resource_list.size() > 0:
		worker.setTargetPosition(resource_list[randi_range(0, resource_list.size() - 1)].global_position)
