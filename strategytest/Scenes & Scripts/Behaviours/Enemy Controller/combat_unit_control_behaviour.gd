extends Node

var controller : Node3D
var controlled_faction : int

func runBehaviour():
	for unit in controller.getUnits():
		if !unit.isActive():
			if !targetKnownUnit():
				if !targetKnownBuilding():
					targetHQ()

func targetKnownUnit():
	return false

func targetKnownBuilding():
	return false

func targetHQ():
	pass

func setControlled(node):
	controller = node
	controlled_faction = controller.getFaction()
