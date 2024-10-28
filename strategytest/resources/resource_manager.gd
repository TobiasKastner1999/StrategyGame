extends Node

# calls for the HQ to have its workers remove references to a removed resource node
func _on_ressource_expended(node):
	$".."/Nav/HQ.excludeResource(node)
