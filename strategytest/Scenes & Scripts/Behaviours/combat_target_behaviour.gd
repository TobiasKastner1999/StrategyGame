extends Node

var run_node : Node3D # the node  the behaviour is operating on

# runs the combat target behaviour
func runBehaviour(node, _delta):
	run_node = node # stores the operating node
	
	if hasEmptyTarget() and hasValidTargets(): # checks if the node has no target, but has options to choose one
		prioritySelectTarget() # if so, selects a new target
	elif !hasEmptyTarget():
		run_node.focusAtTarget() # if the node already has a target, calls to update the node's movement path

# checks if the node has no target
func hasEmptyTarget():
	if (run_node.getActiveTarget() != null and run_node.getTargetMode() == 1) or run_node.getPriorityMovement():
		return false
	return true

# checks if there are any valid new targets near the node
func hasValidTargets():
	if run_node.getNearbyEnemies().size() == 0:
		return false
	return true

# selects a new target based on the node's priority
func prioritySelectTarget():
	var target
	var distance
	
	for enemy in run_node.getNearbyEnemies(): # checks for each potential target near the node
		var enemy_distance = run_node.global_position.distance_to(enemy.global_position)  # checks distance to that target
		# updates target if no target has been chosen yet, the new target has a greater priority, or the new target is of the same priority, but closer to the node
		if target == null \
				or checkTargetPriority(enemy) < checkTargetPriority(target) \
				or (checkTargetPriority(enemy) == checkTargetPriority(target) and enemy_distance < distance):
			target = enemy
			distance = enemy_distance
	
	run_node.setAttackTarget(target) # sets target as the node's new attack target
	run_node.setTargetMode(1)
	run_node.focusAtTarget()

# checks for a target's priority
func checkTargetPriority(target):
	var target_priority = run_node.getTargetPriority() # grabs the node's target priority
	return target_priority.find(target.getType()) # checks for the target's priorization based on that priority
