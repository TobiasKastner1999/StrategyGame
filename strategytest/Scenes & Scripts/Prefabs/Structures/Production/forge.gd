extends Node3D

signal building_menu(building) # to activate the interface when the forge is clicked
signal interface_update() # to update the forge's interface display

const DISPLAY_NAME = "@name_building_forge" # the forge's displayed name
const TARGET_TYPE = "forge" # the forge's combat type
const MAX_HP = 4.0 # the forge's maximum hit points

var faction : int # the faction the forge belongs to
var nearby_observers = []

@onready var greystate = preload("res://Assets/Materials/material_grey_out.tres")
@onready var hp = MAX_HP # the forge's current hit points, initially set to the maximum hit points

# initially sets up the forge's health bar
func _ready():
	$HealthbarContainer/HealthBar.max_value = MAX_HP # adjusts the health bar display to this unit's maximum hp
	$HealthbarContainer/HealthBar.value = hp

# causes the forge to take a given amount of damage
func takeDamage(damage, _attacker):
	hp -= damage # subtracts the damage taken from the current hp
	$HealthBarSprite.visible = true
	$HealthbarContainer/HealthBar.value = hp # updates the health bar display
	if hp <= 0: # removes the forge if it's remaining hp is 0 or less
		if faction == Global.player_faction:
			Global.updateBuildingCount(false)
		queue_free() # then deletes the forge
	interface_update.emit() # calls to update the interface with the new health value

# accesses the forge's interface function
func accessStructure():
	building_menu.emit(self)

# returns the forge's current HP
func getHP():
	return hp

# returns the forge's maximum HP
func getMaxHP():
	return MAX_HP

# returns the forge's display name id
func getDisplayName():
	return DISPLAY_NAME

# returns the forge's status
func getInspectInfo(info):
	pass

# sets the forge's faction to a given value
func setFaction(f : int):
	faction = f # sets the faction
	$HousingBody.material_override = load(Global.getFactionColor(faction)) # sets the correct forge color
	if faction == 1: # when faction is 0
		$OLHousingBody.visible = true # outlaw asset becomes visible
		$OLHousingColl.disabled = false
		get_parent().bake_navigation_mesh() # rebakes the navmesh when spawned
	elif faction == 0: # when faction is 1
		$HousingBody.visible = true # new lights asset becomse visible 
		$ForgeColl.disabled = false
		get_parent().bake_navigation_mesh() # rebakes the navmesh when spawned

# returns the forge's current faction
func getFaction():
	return faction

# returns the target type (forge)
func getType():
	return TARGET_TYPE

# returns the physical size of the forge
func getSize():
	return ($HousingBody.mesh.size.x / 2)

# removes a given unit from the list of the forge's observers
func clearUnitReferences(unit):
	fowExit(unit)

# called when the forge comes into view of a player-controlled unit
func fowEnter(node):
	if node.getFaction() != faction:
		nearby_observers.append(node)

		fowReveal(true) # enables the visibility of the forge
		setGreystate(false) # enables the greystate of the forge

# called when the forge is no longer in view of a player-controlled unit
func fowExit(node):
	if nearby_observers.has(node):
		nearby_observers.erase(node)
		if nearby_observers.size() == 0:
			setGreystate(true) # disables the greystate of the forge

# sets the visibility of the forge to a given state
func fowReveal(bol):
	if visible != bol:
		visible = bol

# sets the greystate of the forge
func setGreystate(bol):
	if bol:
		$HousingBody.material_overlay = greystate
	else:
		$HousingBody.material_overlay = null
