extends Node

# checks through the available behaviours on each physics frame
func runBehaviours(node, delta):
	await $ResourceTargetBehaviour.runBehaviour(node) # chooses a new target if necessary
	if await $MovementBehaviour.runBehaviour(node, delta): # moves the node
		$ResourceAcquisitionBehaviour.runBehaviour(node) # then runs resource acquisition if the node is close enough to its target
