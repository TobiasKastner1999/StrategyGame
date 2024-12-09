extends Node

var run_node : Node3D # the node the behaviour is operating on

# runs the resource targeting behaviour
func runBehaviour(node):
	run_node = node # stores the operating node
	
	if hasEmptyTarget() and notInAcquisition(): # runs the behaviour if the node has no target, and is not currently acquiring resources
		match checkCarryState(): # checks the node's carry state
			0:
				targetResource() # targets a resource if the node is not carrying any
			1:
				targetHQ() # target's the node's base if it is carrying resources

# checks if the node has no target
func hasEmptyTarget():
	if run_node.getDestination() == null or run_node.getDestination() == run_node.getPosition():
		return true # returns true of the node has no active destination, or its destination is its own position
	return false

# checks if the node is not currently acquiring a resource
func notInAcquisition():
	if run_node.getInteractionState() != 1:
		return true # returns true of the node is not in the acquisition state of its interaction
	return false

# checks the node's resource carry state
func checkCarryState():
	return run_node.getResourceState()

# attempts to have the node target a resource
func targetResource():
	if checkForPrevious():
		reTargetPrevious() # if the node has a previous saved resource node, targets that node
	elif checkForKnown():
		targetKnown() # otherwise, targets a different resource node that the node has saved

# checks if the node has a previously saved resource node target
func checkForPrevious():
	if is_instance_valid(run_node.getPrevious()):
		return true # returns true if a saved target exists and is still valid
	return false

# has the node target its previous target
func reTargetPrevious():
	run_node.setTarget(run_node.getPrevious())
	run_node.setTargetMode(0)

# checks if the node knows of any other resource nodes
func checkForKnown():
	if run_node.getKnownResources().size() > 0:
		return true # returns true if there are resources saved on the node
	return false

# has the node target a saved resource from its internal list
func targetKnown():
	var known = run_node.getKnownResources() # retrieves the list of known resources
	var target
	var distance
	
	# then checks for each resource node in the list
	for resource in known:
		if is_instance_valid(resource): # if the node is still valid, proceeds with the check
			var resource_distance = run_node.getPosition().distance_to(resource.global_position)
			if target == null or resource_distance < distance:
				target = resource # overwrites the intended target if no intended target exists yet, or if the new target is closer than the previous
				distance = resource_distance
		else:
			run_node.removeResourceKnowledge(resource) # otherwise clears the resource from the node's list
	
	run_node.setTarget(target) # has the node target the intended target
	run_node.setTargetMode(0)

# has the node target its base
func targetHQ():
	run_node.setTarget(run_node.getHQ())
	run_node.setTargetMode(0)
