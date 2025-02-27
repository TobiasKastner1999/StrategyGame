extends Node

var controller : Node3D # the faction controller this node belongs to
var controlled_faction : int # the faction controlled by this node

# runs the node's sub-behaviours
func runBehaviour():
	# runs the same behaviours for each controlled worker
	for worker in controller.getWorkers().get_children():
		if !worker.isActive(): # checks if the worker is active
			var required = getRequiredResource() # if no, grabs the required resource type from the controller
			if required != null:
				newResourceTarget(worker, required) # if the return is not null, has the worker acquire that resource

# grabs the currently required resource type from the controller
func getRequiredResource():
	return controller.getRequiredResource()

# assigns a given worker a new resource target of a given type
func newResourceTarget(node, target):
	var resource_list = controller.getHQ().getResources() # gets all resources that are near the controlled HQ
	if resource_list.size() == 0:
		resource_list = controller.getResources().get_children() # if there are no resources left near the HQ, gets all resources on the map instead
	if resource_list.size() > 0:
		var resources_temp = resource_list.duplicate()
		for resource in resources_temp:
			if resource.getFaction(controlled_faction) != controlled_faction or resource.getResourceType() != target:
				resource_list.erase(resource) # removes all resources the controlled faction cannot use or that aren't currently required from the list
		if resource_list.size() > 0:
			node.setTarget(resource_list[randi_range(0, resource_list.size() - 1)]) # sends the worker to a random resource from the list

# sets up the node
func setControlled(node):
	controller = node
	controlled_faction = controller.getFaction()
