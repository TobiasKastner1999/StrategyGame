extends Node

# checks through the available behaviours on each physics frame
func runBehaviours(node, delta):
	if await $ThreatDetectionBehaviour.runBehaviour(node): # checks if there are enemies nearby
		await $CombatTargetBehaviour.runBehaviour(node, delta) # if yes, attempts to run the combat targeting
	else:
		await $ResourceTargetBehaviour.runBehaviour(node) # otherwise, attempts to run the resource targeting
	if await $MovementBehaviour.runBehaviour(node, delta): # moves the node, then runs the action behaviours if the node is close enough to its target
		$AttackBehaviour.runBehaviour(node, delta) # attempts to run the attack behaviour (only executed if the node has a valid combat target)
		$ResourceAcquisitionBehaviour.runBehaviour(node) # attempts to run the resource acquisition behaviour (only executed if the node has a valid resource target)
