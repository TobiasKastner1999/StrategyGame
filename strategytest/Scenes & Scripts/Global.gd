extends Node

const BUILDING_COST = 4 # the crystal cost required to construct a new building
var faction_zero_resources = [0, 0] # faction 0's balances in the different resources
var faction_one_resources = [0, 0] # faction 1's balances in the different resources
var player_faction : int # the faction the player has chosen for the current game

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
