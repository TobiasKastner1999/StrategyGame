extends Node3D

var resource = 3


func _ready():
	pass 


#deletes the resource once empty
func _process(delta):
	if resource == 0:
		queue_free()
