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
	if Balance.upgrade1[controlled_faction] and !unit.getUpgradeState():
		for building in controller.getBuildings():
			if building.getType() == "building":
				unit.setDestination(building.global_position)
				return true
	return false

func targetKnownUnit(unit):
	var targets = Global.getKnownPlayerUnits()
	var closest
	var closest_distance
	
	if targets.size() > 0:
		for target in targets:
			var target_distance = unit.global_position.distance_to(target.global_position)
			if closest == null or target_distance < closest_distance:
				closest = target
				closest_distance = target_distance
	
		if unit.isNearBody(closest):
			unit.setAttackTarget(closest)
		else:
			unit.setDestination(closest.global_position)
		return true
	return false

func targetKnownBuilding(unit):
	var targets = Global.getKnownPlayerBuildings()
	var closest
	var closest_distance
	
	if targets.size() > 0:
		for target in targets:
			var target_distance = unit.global_position.distance_to(target.global_position)
			if closest == null or target_distance < closest_distance:
				closest = target
				closest_distance = target_distance
		
		if unit.isNearBody(closest):
			unit.setAttackTarget(closest)
		else:
			unit.setDestination(closest.global_position)
		return true
	return false

func targetHQ(unit):
	var hq = controller.getEnemyHQ()
	if unit.isNearBody(hq):
		unit.setAttackTarget(hq)
	else:
		unit.setDestination(hq.global_position)

func setControlled(node):
	controller = node
	controlled_faction = controller.getFaction()
