extends Node

var controller : Node3D
var controlled_faction : int

func runBehaviour():
	for worker in controller.getWorkers().get_children():
		if !worker.isActive():
			var required = getRequiredResource()
			newResourceTarget(worker, required)

func getRequiredResource():
	return ""

func newResourceTarget(node, target):
	pass
	var resource_list = controller.getHQ().getResources() # gets all resources that are near the HQ
	if resource_list.size() == 0:
		resource_list = controller.getResources().get_children() # if there are no resources left near the HQ, gets all resources on the map instead
	#if resource_list.size() > 0:
		#for resource in resource_list:
			#if resource.getFaction(controlled_faction) != controlled_faction:
				#resource_list.erase(resource) # removes all resources the controlled faction cannot use from the list
		#if (Global.getResource(controlled_faction, 0) < Global.getConstructionCost(1)) and (build_locations[controlled_faction].size() == 3):
			#for resource in resource_list: # if the AI still needs to construct a building, and does not have enough resources to do so
				#if resource.getResourceType() != 0:
					#resource_list.erase(resource) # ignores all resources for units
		#else:
			#for resource in resource_list:
				#if resource.getResourceType() == 0:
					#resource_list.erase(resource) # otherwise, ignores all resources for buildings instead
		#if resource_list.size() == 0:
			#resource_list = resources.get_children() # re-generates the list if ignoring a specific type of resource would cause the list to be empty
		#worker.setTarget(resource_list[randi_range(0, resource_list.size() - 1)]) # sends the worker to a random resource from the list

func setControlled(node):
	controller = node
	controlled_faction = controller.getFaction()
