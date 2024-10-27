extends Node

func _on_ressource_expended(node):
	print("passing on...")
	$".."/HQ.excludeResource(node)
