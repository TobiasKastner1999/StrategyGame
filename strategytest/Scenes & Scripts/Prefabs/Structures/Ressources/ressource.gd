extends Node3D

signal expended(node) # to have workers remove their references of this node

var resource = Balance.resource # how many resources does this node still hold?

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
func getResourceType():
	return resource_type

# returns the resource node's node type
func getType():
	return "resource"

# returns the resource's current visibility state
func isVisible():
	return visible

# returns the resource's global position
func getPosition():
	return global_position

# returns the resource's rotation
func getRotation():
	return rotation

# called when the resource comes into view of a player-controlled unit
func fowEnter(_node):
	fowReveal() # enables the visibility of the resource

# called when the resource is no longer in view of a player-controlled unit
func fowExit(_node):
	pass

# enables the visibility of the resource
func fowReveal():
	if !visible:
		visible = true
