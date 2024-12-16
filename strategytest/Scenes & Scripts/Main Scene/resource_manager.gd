extends Node

signal rebake()

var dummy_prefab = preload("res://Scenes & Scripts/Prefabs/Structures/Ressources/dummy_resource.tscn")

func createDummyResource(type, pos, rot):
	var new_dummy = dummy_prefab.instantiate()
	add_child(new_dummy)
	new_dummy.setUp(type, pos, rot)

# calls for the HQ to have its workers remove references to a removed resource node
func _on_ressource_expended(node):
	if node.isVisible():
		createDummyResource(node.getResourceType(), node.getPosition(), node.getRotation())
	
	$".."/HQBlue.excludeResource(node)
	$".."/HQRed.excludeResource(node)
	rebake.emit() # also calls to re-bake the navmesh to account for the removed object
