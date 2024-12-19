extends Node

var run_node : Node3D # the node the behaviour is operating on

# runs the attack behaviour
func runBehaviour(node, _delta):
	run_node = node # stores the operating node
	
	if combatTargetInRange() and canAttack(): # checks if the target is within range of the node, and if the unit can attack
		attackTarget() # if yes, attacks the target

# checks if the target is within range of the node
func combatTargetInRange():
	var target = run_node.getActiveTarget()
	
	if target != null and target.getType() != "resource" and run_node.getTargetMode() == 1:
		var attack_range = run_node.getAttackRange() # if the node has a target, gets the node's attack range
	
		if run_node.getPosition().distance_to(target.global_position) <= attack_range: # then determines if the target is within the attack range
			return true
	return false

# checks if the node can attack
func canAttack():
	return run_node.getAttackAvailability()

# attacks the target
func attackTarget():
	var target = run_node.getActiveTarget()
	var damage = run_node.getAttackDamage()
	
	target.takeDamage(damage, run_node) # has the target takes the node's damage value from the node
	run_node.startAttackCooldown() # triggers the node's attack cooldown
