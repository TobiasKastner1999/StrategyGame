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
	for enemy in run_node.getNearbyEnemies():
		if enemy.getType() == "combat":
			return true # returns true if there is a non-building enemy in the list
	return false # returns false otherwise
