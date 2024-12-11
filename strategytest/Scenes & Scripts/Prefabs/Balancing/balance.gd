extends Control

const FILE = "res://Data/test.json"


# stats of the different Unit types
@export var ranged_hp = 10
@export var ranged_damage = 1
@export var ranged_range = 10
@export var ranged_attack_speed = 2
@export var ranged_detection = 20
@export var ranged_speed = 20
@export var ranged_cost = 1
@export var ranged_production = 10

@export var scout_hp = 5
@export var scout_damage = 0.5
@export var scout_range = 7.5
@export var scout_attack_speed = 3
@export var scout_detection = 40
@export var scout_speed = 25
@export var scout_cost = 1
@export var scout_production = 5

@export var sniper_hp = 3
@export var sniper_damage = 5
@export var sniper_range = 20
@export var sniper_attack_speed = 5
@export var sniper_detection = 30
@export var sniper_speed = 15
@export var sniper_cost = 3
@export var sniper_production = 15

@export var melee_hp = 15
@export var melee_damage = 2
@export var melee_range = 5
@export var melee_attack_speed = 2
@export var melee_detection = 15
@export var melee_speed = 20
@export var melee_cost = 2
@export var melee_production = 10

@export var worker_hp = 5.0 # the worker's maximum hit points
@export var resources_mined = 1 # the worker's capacity of resources 
@export var worker_damage = 1
@export var worker_range = 5
@export var worker_attack_speed = 3
@export var worker_detection = 15
@export var worker_speed = 10
@export var worker_cost = 0
@export var worker_production = 0


@export var construction_costs = [0, 4, 2] # the construction costs for different types of buildings
@export var faction_zero_resources = [4, 0] # faction 0's balances in the different resources
@export var faction_one_resources = [0, 0] # faction 1's balances in the different resources
@export var unit_max = [2, 2] # how many units can a faction currently have at max?

@export var building_hp = 8 # health for building
@export var building_spawn_delay = 1 # delay when units are spawned
@export var cameara_speed = 0.5 # camera sensitivity
@export var camera_zoom_speed = 5 # speed for zooming
@export var camera_zoom_up_limit = 60 # upper limit for cam zoom
@export var camera_zoom_down_limit = 20 # lower limit for cam zoom


@export var hq_spawn_delay = 10.0 # how often will new workers spawn?
@export var worker_limit = 4 # how many workers can spawn at most?
@export var hq_hp = 20.0 # the hq's maximum hp
@export var resource = 4 # how many resources can be mined

# text to be translated
# title in faction selection
# faction buttons
# Gamestateinfo
# building tab
# unit type buttons
# Game Over screen
# Quit button
# Optionsmenu



#func _ready():
	#var save = FileAccess.open(FILE, FileAccess.WRITE)
	#
#
	#Global.unit_dict["0"]["max_hp"] = ranged_hp
	#Global.unit_dict["0"]["damage_value"] = ranged_damage
	#Global.unit_dict["0"]["attack_range"] = ranged_range
	#Global.unit_dict["0"]["attack_speed"] = ranged_attack_speed
	#Global.unit_dict["0"]["detection_range"] = ranged_detection
	#Global.unit_dict["0"]["speed"] = ranged_speed
	#Global.unit_dict["0"]["resource_cost"] = ranged_cost
	#Global.unit_dict["0"]["production_speed"] = ranged_production
	#
	#Global.unit_dict["1"]["max_hp"] = scout_hp
	#Global.unit_dict["1"]["damage_value"] = scout_damage
	#Global.unit_dict["1"]["attack_range"] = scout_range
	#Global.unit_dict["1"]["attack_speed"] = scout_attack_speed
	#Global.unit_dict["1"]["detection_range"] = scout_detection
	#Global.unit_dict["1"]["speed"] = scout_speed
	#Global.unit_dict["1"]["resource_cost"] = scout_cost
	#Global.unit_dict["1"]["production_speed"] = scout_production
	#
	#Global.unit_dict["2"]["max_hp"] = sniper_hp
	#Global.unit_dict["2"]["damage_value"] = sniper_damage
	#Global.unit_dict["2"]["attack_range"] = sniper_range
	#Global.unit_dict["2"]["attack_speed"] = sniper_attack_speed
	#Global.unit_dict["2"]["detection_range"] = sniper_detection
	#Global.unit_dict["2"]["speed"] = sniper_speed
	#Global.unit_dict["2"]["resource_cost"] = sniper_cost
	#Global.unit_dict["2"]["production_speed"] = sniper_production
	#
	#Global.unit_dict["3"]["max_hp"] = melee_hp
	#Global.unit_dict["3"]["damage_value"] = melee_damage
	#Global.unit_dict["3"]["attack_range"] = melee_range
	#Global.unit_dict["3"]["attack_speed"] = melee_attack_speed
	#Global.unit_dict["3"]["detection_range"] = melee_detection
	#Global.unit_dict["3"]["speed"] = melee_speed
	#Global.unit_dict["3"]["resource_cost"] = melee_cost
	#Global.unit_dict["3"]["production_speed"] = melee_production
	#
	#Global.unit_dict["worker"]["max_hp"] = worker_hp
	#Global.unit_dict["worker"]["damage_value"] = worker_damage
	#Global.unit_dict["worker"]["attack_range"] = worker_range
	#Global.unit_dict["worker"]["attack_speed"] = worker_attack_speed
	#Global.unit_dict["worker"]["detection_range"] = worker_detection
	#Global.unit_dict["worker"]["speed"] = worker_speed
	#Global.unit_dict["worker"]["resource_cost"] = worker_cost
	#Global.unit_dict["worker"]["production_speed"] = worker_production
	#
	#var json_string = JSON.stringify(Global.unit_dict)
	#save.store_line(json_string)
