extends Node

var run_node : Node3D # the node the behaviour is operating on

# runs the target detection behaviour
func runBehaviour(node):
	run_node = node # stores the operating node
	
	if hasNearbyEnemies(): # checks if there are any enemies near the node
		return true
	return false

# checks if there are any enemy units near the node
func hasNearbyEnemies():
	if run_node.getTargetMode() == 1:
		var target_node = run_node.getActiveTarget()
		if target_node == null or !is_instance_valid(target_node) or (target_node.getType() == "hq" and target_node.getFaction() == run_node.getFaction()) or target_node.getType() == "resource":
			run_node.leaveCombatMode()
			return false
		return true
	for enemy in run_node.getNearbyEnemies():
		if enemy.getType() == "combat" or enemy.getType() == "worker":
			return true # returns true if there is a non-building enemy in the list
	return false # returns false otherwise
