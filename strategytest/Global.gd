extends Node

const BUILDING_COST = 4 # the crystal cost required to construct a new building
var crystals = 0 # the player's current crystal balance
var enemy_crystals = 0 # the enemy's current crystal balance
var list = {}





# returns the correct color for a given faction
func getFactionColor(faction):
	match faction:
		0:
			return "res://units/material_friendly.tres"
		1:
			return "res://units/material_enemy.tres"

# adds a given amount of crystals to a faction's stock
func addCrystals(amount, faction):
	match faction:
		0:
			crystals += amount
		1:
			enemy_crystals += amount

# returns the amount of crystals a given faction currently has
func getCrystals(faction):
	match faction:
		0:
			return crystals
		1:
			return enemy_crystals
