extends Node

const BUILDING_COST = 4 # the crystal cost required to construct a new building
var crystals = 0 # the player's current crystal balance

func getFactionColor(faction):
	match faction:
		0:
			return "res://units/material_friendly.tres"
		1:
			return "res://units/material_enemy.tres"
