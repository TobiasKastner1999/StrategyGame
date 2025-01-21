extends Node

var controller : Node3D
var controlled_faction : int

func runBehaviour():
	for worker in controller.getWorkers().get_children():
		if !worker.isActive():
			var required = getRequiredResource()
			if required != null:
				newResourceTarget(worker, required)

func getRequiredResource():
	return controller.getRequiredResource()

func newResourceTarget(node, target):
	var resource_list = controller.getHQ().getResources() # gets all resources that are near the HQ
	if resource_list.size() == 0:
		resource_list = controller.getResources().get_children() # if there are no resources left near the HQ, gets all resources on the map instead
	if resource_list.size() > 0:
		for resource in resource_list:
			if resource.getFaction(controlled_faction) != controlled_faction or resource.getResourceType() != target:
				print(resource)
				resource_list.erase(resource) # removes all resources the controlled faction cannot use from the list
		if resource_list.size() > 0:
			node.setTarget(resource_list[randi_range(0, resource_list.size() - 1)]) # sends the worker to a random resource from the list

func setControlled(node):
	controller = node
	controlled_faction = controller.getFaction()
