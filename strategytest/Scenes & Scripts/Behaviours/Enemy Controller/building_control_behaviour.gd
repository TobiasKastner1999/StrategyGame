extends Node

const UPGRADE_TRESHOLD = 4

var controller : Node3D
var controlled_faction : int
var pursuing_upgrade = false

func runBehaviour():
	if upgradeConditionsFulfilled():
		pursueUpgrade()
	controlForge()

func upgradeConditionsFulfilled():
	if Global.getUnitCount(controlled_faction) >= UPGRADE_TRESHOLD and !Balance.upgrade1[controlled_faction]:
		return true
	return false

func pursueUpgrade():
	pursuing_upgrade = true
	
	for building in controller.getBuildings():
		if building.getType() == "building":
			building.setStatus(false)

func controlForge():
	if pursuing_upgrade and Global.getResource(controlled_faction, 1) >= Global.getUpgradeCost():
		for building in controller.getBuildings():
			if building.getType() == "forge":
				building.startResearch()
				Global.updateResource(controlled_faction, 1, -Global.getUpgradeCost())
				return

func setControlled(node):
	controller = node
	controlled_faction = controller.getFaction()
