extends Node

signal rebake()

# calls for the HQ to have its workers remove references to a removed resource node
func _on_ressource_expended(node):
	$".."/HQBlue.excludeResource(node)
	$".."/HQRed.excludeResource(node)
	rebake.emit() # also calls to re-bake the navmesh to account for the removed object
