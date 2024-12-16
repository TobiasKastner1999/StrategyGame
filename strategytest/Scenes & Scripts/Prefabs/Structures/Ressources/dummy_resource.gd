extends StaticBody3D

var material_purple = preload("res://Assets/Materials/material_purple.tres")
var material_green = preload("res://Assets/Materials/material_green.tres")

func setUp(type, pos, rot):
	match type:
		0:
			$ResourceBody.set_surface_override_material(0, material_purple)
		1:
			$ResourceBody.set_surface_override_material(0, material_green)
	
	global_position = pos
	rotation = rot
	scale = Vector3(2, 2, 2)

func fowReveal():
	queue_free()
