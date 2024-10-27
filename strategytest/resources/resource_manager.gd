extends Node

func _on_ressource_expended(node):
	$".."/HQ.excludeResource(node)
