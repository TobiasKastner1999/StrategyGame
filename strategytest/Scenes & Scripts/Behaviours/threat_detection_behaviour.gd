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
	if run_node.getNearbyEnemies().size() > 0:
		return true # returns true if the list tracking enemy units near the node isn't empty
	else:
		return false # returns false otherwise
