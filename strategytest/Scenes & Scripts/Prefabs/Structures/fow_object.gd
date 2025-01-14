extends Node3D

var nearby_observers = []

@onready var greystate = preload("res://Assets/Materials/material_grey_out.tres")

# returns the object's node type
func getType():
	return "environment"

# removes a given unit from the list of the object's observers
func clearUnitReferences(unit):
	fowExit(unit)

# called when the node comes into view of a player-controlled unit
func fowEnter(node):
	nearby_observers.append(node)
	fowReveal(true) # enables the visibility of the node
	setGreystate(false) # disables the node's greystate

# called when the node is no longer in view of a player-controlled unit
func fowExit(node):
	if nearby_observers.has(node):
		nearby_observers.erase(node)
		if nearby_observers.size() == 0:
			setGreystate(true) # enables the node's greystate

# sets the visibility of the node to a given state
func fowReveal(bol):
	if visible != bol:
		visible = bol

# sets the node's greystate
func setGreystate(bol):
	if bol:
		for node in get_children():
			if node is MeshInstance3D:
				node.material_overlay = greystate
	else:
		for node in get_children():
			if node is MeshInstance3D:
				node.material_overlay = null
