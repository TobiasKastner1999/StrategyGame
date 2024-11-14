extends Node3D

signal building_menu(building) # to activate the interface when the building is clicked
signal interface_update() # to update the building's interface display

const DISPLAY_NAME = "Housing" # the building's displayed name
const TARGET_TYPE = "building" # the building's combat type
const MAX_HP = 4.0 # the building's maximum hit points

var function_active = true
var faction : int # the faction the building belongs to

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
		queue_free() # then deletes the building
	interface_update.emit() # calls to update the interface with the new health value

# accesses the building's interface function
func accessStructure():
	building_menu.emit(self)

# toggles the building's production status
func toggleStatus():
	function_active = !function_active 
	$HousingPause.visible = !function_active 

# sets the building's faction to a given value
func setFaction(f : int):
	faction = f # sets the faction
	$HousingBody.material_override = load(Global.getFactionColor(faction)) # sets the correct building color

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
