extends Node3D


var faction_zero_resources = [0, 0] # faction 0's balances in the different resources
var faction_one_resources = [0, 0] # faction 1's balances in the different resources

var player_faction : int # the faction the player has chosen for the current game
var list = {} # dictionary to store units and building to project on the minimap
var list_counter = 1 # sets the start value of the dictionary to 1 instead of 0 

var selected_language : String = "en" # the language currently selected by the player

var unit_count = [0, 0] # how many units does each faction currently have?
var units_queued = [0, 0] # how many units does each faction currently have in active production?
var upgrade_queued = [false, false] # are the factions currently researching an upgrade?
var player_building_count : int = 0 # how many building's has the player constructed?
var cam = null # stores mainscene camera
var tree = null

var known_player_units = [] # a list of the player's units known to the AI
var known_player_buildings = [] # a list of the player's buildings known to the AI

@onready var unit_dict = JSON.parse_string(FileAccess.get_file_as_string("res://Data/unit_data.json")) # a dictionary of the different unit types and their properties
@onready var language_dict = JSON.parse_string(FileAccess.get_file_as_string("res://Data/language_data.json")) # a dictionary of the different translation of texts in different languages

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
			Balance.faction_zero_resources[type] += amount
		1:
			Balance.faction_one_resources[type] += amount

# returns a given faction's current balance of a given resource
func getResource(faction, type):
	match faction:
		0:
			return Balance.faction_zero_resources[type]
		1:
			return Balance.faction_one_resources[type]

# returns a given faction's maximum possible balance of a given resource
func getMaxResource(faction, type):
	match faction:
		0:
			return Balance.faction_zero_resource_limits[type]
		1:
			return Balance.faction_one_resource_limits[type]

# modifies a given faction's maximum possible balance of a given resource by a given value
func updateResourceCapacity(faction, capacity_a, capacity_b):
	match faction:
		0:
			Balance.faction_zero_resource_limits[0] += capacity_a
			Balance.faction_zero_resource_limits[1] += capacity_b
		1:
			Balance.faction_one_resource_limits[0] += capacity_a
			Balance.faction_one_resource_limits[1] += capacity_b

# returns the combat unit upgrade cost
func getUpgradeCost():
	return Balance.upgrade_cost

# returns whether or not a given faction is currently researching an upgrade
func getResearchQueue(faction):
	return upgrade_queued[faction]

# sets a given faction's upgrade research state to a given value
func setResearchQueue(faction, bol):
	upgrade_queued[faction] = bol

# returns the correct text with the given id in the player's chosen language
func getText(id):
	if language_dict.has(id):
		return language_dict[id][selected_language]
	return "" # if the id is invalid, an empty string is returned instead

func setCursor(image):
	var cursor = load(image)
	Input.set_custom_mouse_cursor(cursor)

func defaultCursor():
	Input.set_custom_mouse_cursor(load("res://Assets/UI/CursorNormal.png"))

# returns to cost for a specified building type
func getConstructionCost(building_type):
	return Balance.construction_costs[building_type]

# updates a faction's number of current units
func updateUnitCount(faction, value):
	unit_count[faction] += value

# returns a faction's number of current units
func getUnitCount(faction):
	return unit_count[faction]

# updates the number of a given faction's in-production units by a given value
func updateQueuedUnitCount(faction, value):
	units_queued[faction] += value

# returns a given faction's number of in-production units
func getQueuedUnitCount(faction):
	return units_queued[faction]

# returns a given faction's full unit count, including active units and in-production units
func getFullUnitCount(faction):
	return (unit_count[faction] + units_queued[faction])

# updates a faction's maximum number of units
func updateUnitLimit(faction, value):
	Balance.unit_max[faction] += value

# returns a faction's maximum number of units
func getUnitLimit(faction):
	return Balance.unit_max[faction]

# adds or removes a constructed or destroyed building from the player's count
func updateBuildingCount(constructed):
	if constructed:
		player_building_count += 1
	else:
		player_building_count -= 1

# returns the number of the player's current buildings
func getBuildingCount():
	return player_building_count

func getPlayerBuildings(type):
	var buildings = tree.get_nodes_in_group("Building")
	for building in buildings:
		if building.getFaction() != Global.player_faction or building.getType() != type:
			buildings.erase(building)
	return buildings.size()

# returns the current list of the AI's known player-controlled units
func getKnownPlayerUnits():
	return known_player_units

# returns the current list of the AI's known player-controlled units
func getKnownPlayerBuildings():
	return known_player_buildings

# adds a target to the AI's knowledge
func addKnownTarget(target):
	match target.getType():
		"building":
			known_player_buildings.append(target) # if the target is a building, adds it to the building list
		"forge":
			known_player_buildings.append(target) # if the target is a forge, adds it to the building list
		
		"combat":
			known_player_units.append(target) # if the target is a combat unit, adds it to the unit list
		"worker":
			known_player_units.append(target) # if the target is a worker, adds it to the unit list

# attempts to remove a target from the AI's knowledge
func removeKnownTarget(target):
	match target.getType():
		"building":
			if known_player_buildings.has(target):
				known_player_buildings.erase(target) # if the target is a building known to the AI, removes it from the building list
		"forge":
			if known_player_buildings.has(target):
				known_player_buildings.erase(target) # if the target is a forge known to the AI, removes it from the building list
		
		"combat":
			if known_player_units.has(target) and !target.hasNearbyAI():
				known_player_units.erase(target) # if the target is a combat unit known to the AI, which has no nearby AI units, removes it from the unit list
		"worker":
			if known_player_units.has(target) and !target.hasNearbyAI():
				known_player_units.erase(target) # if the target is a worker known to the AI, which has no nearby AI units, removes it from the unit list

# add a new entry into a free slot in the dictionary
func add_to_list(positionX, positionY, faction, id, dot, worker):
	Global.list[list_counter] = {"positionX" : positionX, "positionY" : positionY, "faction" : faction , "id" : id, "dot": dot, "worker" : worker}
	list_counter += 1

func healthbar_rotation(healthbar): # funtion to let the health/progressbars face the main camera
	healthbar.look_at(cam)

