extends Node

var run_node : Node3D # the node the behaviour is operating on

# runs the resource acquisition behaviour
func runBehaviour(node):
	run_node = node # stores the operating node
	
	match getTargetType():
		0:
			depositResource()
		1:
			match checkInteractionState():
				0:
					startAcquisition()
				1:
					return false
				2:
					finishAcquisition()

func getTargetType():
	if run_node.getActiveTarget() != null:
		match run_node.getActiveTarget().getType():
			"resource":
				return 1
			_:
				return 0
	return null

func depositResource():
	Global.updateResource(run_node.getFaction(), run_node.getResource()[0], run_node.getResource()[1]) # adds crystal to player's resources
	run_node.setResource([0,0])

func checkInteractionState():
	return run_node.getInteractionState()

func startAcquisition():
	run_node.advanceInteractionState()
	run_node.startMiningState()

func finishAcquisition():
	var resource = run_node.getActiveTarget()
	run_node.advanceInteractionState()
	
	if is_instance_valid(resource):
		run_node.setResource([resource.getResourceType(), 1])
		resource.takeResource()
