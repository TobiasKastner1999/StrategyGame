extends Node

var controller : Node3D # the faction controller this node belongs to
var controlled_faction : int # the faction controlled by this node

# executes the sub-behaviours
func runBehaviour():
	# runs the sub-behaviours for each controlled combat unit
	for unit in controller.getUnits():
		if !unit.isActive(): # checks if the unit is active
			if !returnForUpgrade(unit): # if no, attempts to have the unit return for an upgrade
				if !targetKnownUnit(unit): # otherwise, attempts to have the unit target a known enemy units
					if !targetKnownBuilding(unit): # otherwise, attempts to have the unit target a known enemy building
						targetHQ(unit) # otherwise, has the unit target the enemy HQ

# atempts to have a given unit return for an upgrade
func returnForUpgrade(unit):
	# checks if the upgrade is available, and the unit hasn't been upgraded yet
	if Balance.upgrade1[controlled_faction] and !unit.getUpgradeState():
		for building in controller.getBuildings():
			# finds the first barracks controlled by the faction
			if building.getType() == "building":
				unit.setDestination(building.global_position) # sets that barracks as the unit's movement target
				return true
	return false # otherwise, returns false

# attempts to have a given unit target a known player-controlled unit
func targetKnownUnit(unit):
	var targets = Global.getKnownPlayerUnits() # grabs all known player units
	var closest
	var closest_distance
	
	# if there are any known units
	if targets.size() > 0:
		# checks for each known unit
		for target in targets:
			if is_instance_valid(target):
				var target_distance = unit.global_position.distance_to(target.global_position)
				if closest == null or target_distance < closest_distance:
					closest = target # sets as new priority target if it is closer than any other
					closest_distance = target_distance
			else:
				Global.known_player_units.erase(target)
		if closest != null:
			if unit.isNearBody(closest):
				unit.setAttackTarget(closest) # sets closest as attack target if the target is in attack range
			else:
				unit.setDestination(closest.global_position) # otherwise, sets as movement destination instead
			return true
	return false # otherwise, returns false

# attempts to have a given unit target a known player-controlled building
func targetKnownBuilding(unit):
	var targets = Global.getKnownPlayerBuildings() # grabs all known player buildings
	var closest
	var closest_distance
	
	# if there are any known buildings
	if targets.size() > 0:
		# checks for each known building
		for target in targets:
			if is_instance_valid(target):
				var target_distance = unit.global_position.distance_to(target.global_position)
				if closest == null or target_distance < closest_distance:
					closest = target # sets as new priority target if it is closer than any other
					closest_distance = target_distance
			else:
				Global.known_player_buildings.erase(target)
		
		if closest != null:
			if unit.isNearBody(closest):
				unit.setAttackTarget(closest) # sets closest as attack target if the target is in attack range
			else:
				unit.setDestination(closest.global_position) # otherwise, sets as movement destination instead
			return true
	return false # otherwise, returns false

# has a given unit target the player's HQ
func targetHQ(unit):
	var hq = controller.getEnemyHQ()
	if unit.isNearBody(hq):
		unit.setAttackTarget(hq) # sets HQ as attack target if it is in attack range
	else:
		unit.setDestination(hq.global_position) # otherwise, sets it as movement destination instead

# sets up the node
func setControlled(node):
	controller = node
	controlled_faction = controller.getFaction()
