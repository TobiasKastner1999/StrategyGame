extends Node3D

signal expended(node) # to have workers remove their references of this node

var resource = 3 # how many resources does this node still hold?

# removes a resource from the node
func takeResource():
	resource -= 1
	# checks if the resource is empty now
	if resource <= 0:
		expended.emit($ResourceBody/ResourceStaticBody) # calls to remove references
		queue_free() # then removes the node
