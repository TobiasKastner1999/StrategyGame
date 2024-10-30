extends Node

const BUILDING_COST = 4 # the crystal cost required to construct a new building
var crystals = 0 # the player's current crystal balance
var enemy_crystals = 0 # the enemy's current crystal balance

func getFactionColor(faction):
	match faction:
		0:
			return "res://units/material_friendly.tres"
		1:
			return "res://units/material_enemy.tres"

func addCrystals(amount, faction):
	match faction:
		0:
			crystals += amount
		1:
			enemy_crystals += amount

func getCrystals(faction):
	match faction:
		0:
			return crystals
		1:
			return enemy_crystals
