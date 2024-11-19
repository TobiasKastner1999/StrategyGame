extends Node3D

signal expended(node) # to have workers remove their references of this node

var resource = 200 # how many resources does this node still hold?

@export var resource_type : int # the type of resource this node contains

# called when the node is first initialized
func _ready():
	match resource_type: # checks for the node's resource type, and sets the texture color accordingly
		0:
			$ResourceBody.set_surface_override_material(0, load("res://Assets/Materials/material_purple.tres"))
		1:
			$ResourceBody.set_surface_override_material(0, load("res://Assets/Materials/material_green.tres"))

# removes a resource from the node
func takeResource():
	resource -= 1
	# checks if the resource is empty now
	if resource <= 0:
		expended.emit(self) # calls to remove references
		queue_free() # then removes the node

# returns the node's resource type
func getType():
	return resource_type
