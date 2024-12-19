extends StaticBody3D

var material_purple = preload("res://Assets/Materials/material_purple.tres") # the material for a purple resource
var material_green = preload("res://Assets/Materials/material_green.tres") #  the material for a green resource

# sets up the new dummy node
func setUp(type, pos, rot):
	match type: # sets the correct color material
		0:
			$ResourceBody.set_surface_override_material(0, material_purple)
		1:
			$ResourceBody.set_surface_override_material(0, material_green)
	
	# sets the other properties
	global_position = pos
	rotation = rot
	scale = Vector3(2, 2, 2)

func clearUnitReferences(_unit):
	pass

# called when the dummy comes into view of a player-controlled unit
func fowEnter(_node):
	queue_free() # removes the dummy

func fowExit(_node):
	pass
