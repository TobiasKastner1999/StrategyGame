extends Node

# checks through the available behaviours on each physics frame
func runBehaviours(node, delta):
	for behaviour in get_children():
		await(behaviour.runBehaviour(node, delta)) # runs each behaviour in sequence
