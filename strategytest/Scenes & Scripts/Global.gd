extends Node

const BUILDING_COST = 4 # the crystal cost required to construct a new building
var crystals = [0, 0] # the different factions' current crystal balances
var player_faction : int # the faction the player has chosen for the current game

# returns the correct color for a given faction
func getFactionColor(faction):
	match faction:
		0:
			return "res://Assets/Materials/material_friendly.tres"
		1:
			return "res://Assets/Materials/material_enemy.tres"

# adds a given amount of crystals to a faction's stock
func addCrystals(amount, faction):
	crystals[faction] += amount

# returns the amount of crystals a given faction currently has
func getCrystals(faction):
	return crystals[faction]
