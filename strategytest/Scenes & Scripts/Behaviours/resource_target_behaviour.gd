extends Node

var run_node : Node3D # the node the behaviour is operating on

# runs the resource targeting behaviour
func runBehaviour(node):
	run_node = node # stores the operating node
	
	if hasEmptyTarget() and notInAcquisition():
		match checkCarryState():
			0:
				targetCrystal()
			1:
				targetHQ()

func hasEmptyTarget():
	if run_node.getDestination() == null or run_node.getDestination() == run_node.getPosition():
		return true
	return false

func notInAcquisition():
	if run_node.getInteractionState() != 1:
		return true
	return false

func checkCarryState():
	return run_node.getResourceState()

func targetCrystal():
	if checkForPrevious():
		reTargetPrevious()
	elif checkForKnown():
		targetKnown()

func checkForPrevious():
	if is_instance_valid(run_node.getPrevious()):
		return true
	return false

func reTargetPrevious():
	run_node.setTarget(run_node.getPrevious())

func checkForKnown():
	if run_node.getKnownResources().size() > 0:
		return true
	return false

func targetKnown():
	var known = run_node.getKnownResources()
	var target
	var distance
	
	for resource in known:
		if is_instance_valid(resource):
			var resource_distance = run_node.getPosition().distance_to(resource.global_position)
			if target == null or resource_distance < distance:
				target = resource
				distance = resource_distance
		else:
			run_node.removeResourceKnowledge(resource)
	
	run_node.setTarget(target)

func targetHQ():
	run_node.setTarget(run_node.getHQ())
