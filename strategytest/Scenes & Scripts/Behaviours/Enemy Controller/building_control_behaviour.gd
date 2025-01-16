extends Node

var controller : Node3D
var controlled_faction : int

func runBehaviour():
	var buildings = controller.getBuildings()
	for building in buildings:
		match building.getType():
			"HQ":
				controlHQ(building)
			"building":
				controlBarracks(building)
			"forge":
				controlForge(building)

func controlHQ(hq):
	pass

func controlBarracks(barracks):
	pass

func controlForge(forge):
	pass

func setControlled(node):
	controller = node
	controlled_faction = controller.getFaction()
