extends Node3D

signal building_menu(building) # to activate the interface when the building is clicked
signal interface_update() # to update the building's interface display

const DISPLAY_NAME = "@name_building_housing" # the building's displayed name
const TARGET_TYPE = "building" # the building's combat type
const MAX_HP = 4.0 # the building's maximum hit points
const CAPACITY = 5 # how many units the building can hold

var function_active = true
var faction : int # the faction the building belongs to
var nearby_observers = []

@onready var greystate = preload("res://Assets/Materials/material_grey_out.tres")
@onready var hp = MAX_HP # the building's current hit points, initially set to the maximum hit points

# prepares to spawn a new unit when first built
func _ready():

	$HealthbarContainer/HealthBar.max_value = MAX_HP # adjusts the health bar display to this unit's maximum hp
	$HealthbarContainer/HealthBar.value = hp

# causes the building to take a given amount of damage
func takeDamage(damage, _attacker):
	hp -= damage # subtracts the damage taken from the current hp
	$HealthBarSprite.visible = true
	$HealthbarContainer/HealthBar.value = hp # updates the health bar display
	if hp <= 0: # removes the building if it's remaining hp is 0 or less
		if faction == Global.player_faction:
			Global.updateBuildingCount(false)
		Global.updateUnitLimit(faction, -CAPACITY)
		queue_free() # then deletes the building
	interface_update.emit() # calls to update the interface with the new health value

# accesses the building's interface function
func accessStructure():
	building_menu.emit(self)

# toggles the building's production status
func toggleStatus():
	function_active = !function_active 
	$HousingPause.visible = !function_active
	
	if function_active:
		Global.updateUnitLimit(faction, CAPACITY)
	else:
		Global.updateUnitLimit(faction, -CAPACITY)

# sets the building's faction to a given value
func setFaction(f : int):
	faction = f # sets the faction
	$HousingBody.material_override = load(Global.getFactionColor(faction)) # sets the correct building color
	Global.updateUnitLimit(faction, CAPACITY)
	if faction == 0:
		$OL_forge.visible = true
	elif faction == 1:
		$HousingBody.visible = true

# returns the building's current faction
func getFaction():
	return faction

# returns the building's function status
func getStatus():
	return function_active

# returns the target type (building)
func getType():
	return TARGET_TYPE

# returns the physical size of the building
func getSize():
	return ($HousingBody.mesh.size.x / 2)

# removes a given unit from the list of the housing's observers
func clearUnitReferences(unit):
	fowExit(unit)

# called when the housing comes into view of a player-controlled unit
func fowEnter(node):
	if node.getFaction() != faction:
		nearby_observers.append(node)

		fowReveal(true) # enables the visibility of the housing
		setGreystate(false) # enables the greystate of the housing


# called when the housing is no longer in view of a player-controlled unit
func fowExit(node):
	if nearby_observers.has(node):
		nearby_observers.erase(node)
		if nearby_observers.size() == 0:
			setGreystate(true) # disables the greystate of the housing

# sets the visibility of the housing to a given state
func fowReveal(bol):
	if visible != bol:
		visible = bol

# sets the greystate of the housing
func setGreystate(bol):
	if bol:
		$HousingBody.material_overlay = greystate
	else:
		$HousingBody.material_overlay = null
