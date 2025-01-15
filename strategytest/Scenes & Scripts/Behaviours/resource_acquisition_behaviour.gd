extends Node

var run_node : Node3D # the node the behaviour is operating on

# runs the resource acquisition behaviour
func runBehaviour(node):
	run_node = node # stores the operating node
	
	match getTargetType(): # checks what type of target the node is targeting
		0:
			if canDeposit():
				depositResource() # if the target is the base, deposits the resource
		1:
			match checkInteractionState(): # if the target is a resource, checks the interaction state
				0:
					startAcquisition() # if acquisition has not yet started, start it
				1:
					return false # if acquisition is in progress, do nothing
				2:
					finishAcquisition() # if acquisition has finished, acquire the resource

# returns the node's current target type
func getTargetType():
	if run_node.getActiveTarget() != null and run_node.getTargetMode() == 0:
		match run_node.getActiveTarget().getType():
			"resource":
				return 1 # returns 1 if the node is targeting a resource
			_:
				return 0 # returns 0 otherwise (if the node is targeting its base)
	return null # returns null if the node has no target

func canDeposit():
	var faction = run_node.getFaction()
	var resource_type = run_node.getResource()[0]
	
	if Global.getResource(faction, resource_type) < Global.getMaxResource(faction, resource_type):
		return true
	return false

# deposits the node's carried resource at the base
func depositResource():
	Global.updateResource(run_node.getFaction(), run_node.getResource()[0], run_node.getResource()[1]) # adds resource to player's resources
	run_node.clearResource() # resets the node's carried resource

# returns the node's interaction state
func checkInteractionState():
	return run_node.getInteractionState()

# calls to have the node start its acquisition
func startAcquisition():
	run_node.advanceInteractionState()
	run_node.startMiningState()

# calls to have the node conclude its acquisition
func finishAcquisition():
	var resource = run_node.getActiveTarget()
	run_node.advanceInteractionState()
	
	if is_instance_valid(resource):
		run_node.setResource([resource.getResourceType(), Balance.resources_mined]) # adds resource to the node if the resource target still exists
		resource.takeResource()
