extends Node

signal rebake()

# calls for the HQ to have its workers remove references to a removed resource node
func _on_ressource_expended(node):
	$".."/HQFriendly.excludeResource(node)
	$".."/HQEnemy.excludeResource(node)
	rebake.emit()
