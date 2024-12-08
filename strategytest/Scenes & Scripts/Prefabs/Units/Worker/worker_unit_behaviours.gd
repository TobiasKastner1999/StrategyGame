extends Node

# checks through the available behaviours on each physics frame
func runBehaviours(node, delta):
	await $ResourceTargetBehaviour.runBehaviour(node)
	if await $MovementBehaviour.runBehaviour(node, delta):
		$ResourceAcquisitionBehaviour.runBehaviour(node)
