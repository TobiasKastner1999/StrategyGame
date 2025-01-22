extends Node

var controller : Node3D
var controlled_faction : int

func runBehaviour():
	for unit in controller.getUnits():
		if !unit.isActive():
			if !returnForUpgrade(unit):
				if !targetKnownUnit(unit):
					if !targetKnownBuilding(unit):
						targetHQ(unit)

func returnForUpgrade(unit):
	if Balance.upgrade1[controlled_faction]:
		return true
	return false

func targetKnownUnit(unit):
	return false

func targetKnownBuilding(unit):
	return false

func targetHQ(unit):
	pass

func setControlled(node):
	controller = node
	controlled_faction = controller.getFaction()
