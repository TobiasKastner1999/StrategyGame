extends Node3D

signal expended(node)

var resource = 3

# deletes the resource once empty
func takeResource():
	resource -= 1
	if resource <= 0:
		print("deleted!")
		expended.emit($ResourceBody/ResourceStaticBody)
		queue_free()
