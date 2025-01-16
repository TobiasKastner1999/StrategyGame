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

func setControlled(node):
	controller = node
	controlled_faction = controller.getFaction()
