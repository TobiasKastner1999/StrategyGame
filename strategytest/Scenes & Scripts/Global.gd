extends Node

const CONSTRUCTION_COSTS = [0, 4, 2] # the construction costs for different types of buildings

var faction_zero_resources = [8, 0] # faction 0's balances in the different resources
var faction_one_resources = [0, 0] # faction 1's balances in the different resources
var player_faction : int # the faction the player has chosen for the current game
var list = {}
var list_counter = 1



var unit_max = [2, 2] # how many units can a faction currently have at max?
var unit_count = [0, 0] # how many units does each faction currently have?
var player_building_count : int = 0 # how many building's has the player constructed?

@onready var unit_dict = JSON.parse_string(FileAccess.get_file_as_string("res://Data/unit_types.json")) # a dictionary of the different unit types and their properties

# returns the correct color for a given faction
func getFactionColor(faction):
	match faction:
		0:
			return "res://Assets/Materials/material_blue.tres"
		1:
			return "res://Assets/Materials/material_red.tres"

# returns the correct selection color for a given faction
func getSelectedFactionColor(faction):
	match faction:
		0:
			return "res://Assets/Materials/material_blue_selected.tres"
		1:
			return "res://Assets/Materials/material_red_selected.tres"

# adds or removes a given amount of a given resource to a faction's stock
func updateResource(faction, type, amount):
	match faction:
		0:
			faction_zero_resources[type] += amount
		1:
			faction_one_resources[type] += amount

# returns a given faction's current balance of a given resource
func getResource(faction, type):
	match faction:
		0:
			return faction_zero_resources[type]
		1:
			return faction_one_resources[type]


# returns to cost for a specified building type
func getConstructionCost(building_type):
	return CONSTRUCTION_COSTS[building_type]

# updates a faction's number of current units
func updateUnitCount(faction, value):
	unit_count[faction] += value

# returns a faction's number of current units
func getUnitCount(faction):
	return unit_count[faction]

# updates a faction's maximum number of units
func updateUnitLimit(faction, value):
	unit_max[faction] += value

# returns a faction's maximum number of units
func getUnitLimit(faction):
	return unit_max[faction]

# adds or removes a constructed or destroyed building from the player's count
func updateBuildingCount(constructed):
	if constructed:
		player_building_count += 1
	else:
		player_building_count -= 1

# returns the number of the player's current buildings
func getBuildingCount():
	return player_building_count

# add a new entry into a free slot in the dictionary
func add_to_list(positionX, positionY, faction, id, dot, worker):
	Global.list[list_counter] = {"positionX" : positionX, "positionY" : positionY, "faction" : faction , "id" : id, "dot": dot, "worker" : worker}
	list_counter += 1

