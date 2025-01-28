extends Node

const UPGRADE_TRESHOLD = 4 # the threshold of trained units above which the AI will pursue an upgrade

var controller : Node3D # the faction controller this node belongs to
var controlled_faction : int # the faction controlled by this node
var pursuing_upgrade = false # is the node currently pursuing an upgrade for its faction?

# runs the sub-behaviours
func runBehaviour():
	if upgradeConditionsFulfilled(): # checks if the conditions for pursuing an upgrade are met
		pursueUpgrade() # if so, starts pursuing an upgrade
	controlForge() # controls the forge's activity

# checks if the conditions for pursuing an upgrade are met
func upgradeConditionsFulfilled():
	if Global.getUnitCount(controlled_faction) >= UPGRADE_TRESHOLD and !Balance.upgrade1[controlled_faction] and !Global.getResearchQueue(controlled_faction):
		return true # returns true if the controlled faction meets the unit threshold, and hasn't acquired an upgrade yet
	return false

# starts pursuing an upgrade
func pursueUpgrade():
	pursuing_upgrade = true
	setUnitProduction(false) # disables unit production on all controlled barracks

# sets the unit production on all controlled barracks to a given state
func setUnitProduction(state):
	for building in controller.getBuildings():
		if building.getType() == "building":
			building.setStatus(state)

# controls the forge's activity
func controlForge():
	if pursuing_upgrade and Global.getResource(controlled_faction, 1) >= Global.getUpgradeCost():
		# executes if purusing an upgrade, and if the upgrade cost is met
		for building in controller.getBuildings():
			if building.getType() == "forge": # finds the first available controlled forge
				building.startResearch() # starts research on that forge
				Global.updateResource(controlled_faction, 1, -Global.getUpgradeCost()) # removes the upgrade cost
				pursuing_upgrade = false
				setUnitProduction(true) # re-enables unit production on all controlled barracks
				return # then exits the search loop

# sets up the node
func setControlled(node):
	controller = node
	controlled_faction = controller.getFaction()
