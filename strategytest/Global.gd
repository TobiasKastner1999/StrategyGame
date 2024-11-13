extends Node

const BUILDING_COST = 0 # the crystal cost required to construct a new building
var crystals = 0 # the player's current crystal balance
var enemy_crystals = 0 # the enemy's current crystal balance
var list = {}
var list_counter = 1
var list_soldiers = {}
var list_soldiers_counter = 1



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

# add a new entry into a free slot in the dictionary
func add_to_list(positionX, positionY, faction, id, dot, worker):
	Global.list[list_counter] = {"positionX" : positionX, "positionY" : positionY, "faction" : faction , "id" : id, "dot": dot, "worker" : worker}
	list_counter += 1

func add_to_list_soldiers(positionX, positionY, faction, id, dot, worker):
	Global.list_soldiers[list_soldiers_counter] = {"positionX" : positionX, "positionY" : positionY, "faction" : faction , "id" : id, "dot": dot, "soldier" : worker}
	list_soldiers_counter += 1
