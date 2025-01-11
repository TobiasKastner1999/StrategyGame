extends Node3D

signal expended(node) # to have workers remove their references of this node

var resource = Balance.resource # how many resources does this node still hold?
var nearby_observers = []

@onready var greystate = preload("res://Assets/Materials/material_grey_out.tres")
@export var resource_type : int # the type of resource this node contains
@export var faction_skin: int # sets the skin based on the faction

# called when the node is first initialized
func _ready():

	match resource_type: # checks for the node's resource type, and sets the texture color accordingly
		0:
			$Scrap.visible = true
		1:
			$Ore.visible = true
	match faction_skin:
		0:
			pass
		1:
			$OreGreen.visible = true
			$Scrap.visible = false



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

# removes a given unit from the list of the resource's observers
func clearUnitReferences(unit):
	fowExit(unit)

# called when the resource comes into view of a player-controlled unit
func fowEnter(node):
	nearby_observers.append(node)
	fowReveal(true) # enables the visibility of the resource
	setGreystate(false) # disables the resource's greystate

# called when the resource is no longer in view of a player-controlled unit
func fowExit(node):
	if nearby_observers.has(node):
		nearby_observers.erase(node)
		if nearby_observers.size() == 0:
			setGreystate(true) # enables the resource's greystate

# sets the visibility of the resource to a given state
func fowReveal(bol):
	if visible != bol:
		visible = bol

# sets the resource's greystate
func setGreystate(bol):
	if bol:
		$Ore.material_overlay = greystate
		$Scrap.material_overlay = greystate
	else:
		$Ore.material_overlay = null
		$Scrap.material_overlay = null
