extends Control

const FILE = "res://Data/test.json"

var upgrade1 = [false, false]


# stats of the different Unit types
# stats for the dome guard
@export var Guard_hp = 70
@export var Guard_damage = 5
@export var Guard_range = 15
@export var Guard_attack_speed = 2
@export var Guard_detection = 20
@export var Guard_speed = 15
@export var Guard_cost = 80
@export var Guard_production = 30

# stats of the upgraded ranged unit
@export var u_ranged_hp = 20
@export var u_ranged_damage = 2
@export var u_ranged_range = 30
@export var u_ranged_attack_speed = 3
@export var U_ranged_detection = 20
@export var u_ranged_speed = 30
@export var u_ranged_cost = 1
@export var u_ranged_production = 5

# titan stats
@export var titan_hp = 150
@export var titan_damage = 8
@export var titan_range = 10
@export var titan_attack_speed = 4
@export var titan_detection = 15
@export var titan_speed = 8.5
@export var titan_cost = 150
@export var titan_production = 40

# dust runner
@export var runner_hp = 80
@export var runner_damage = 10
@export var runner_range = 20
@export var runner_attack_speed = 2
@export var runner_detection = 20
@export var runner_speed = 15
@export var runner_cost = 50
@export var runner_production = 25

# ash sentinel
@export var sentinel_hp = 120
@export var sentinel_damage = 9
@export var sentinel_range = 20
@export var sentinel_attack_speed = 2
@export var sentinel_detection = 20
@export var sentinel_speed = 20
@export var sentinel_cost = 130
@export var sentinel_production = 30

# Ashfolk worker stats
@export var worker_hp = 50
@export var worker_damage = 5
@export var worker_range = 10
@export var worker_attack_speed = 2
@export var worker_detection = 15
@export var worker_speed = 10
@export var worker_cost = 25
@export var worker_production = 10.0

# stats for the New lights worker
@export var worker_robot_hp = 50
@export var worker_robot_damage = 4
@export var worker_robot_range = 20
@export var worker_robot_attack_speed = 2
@export var worker_robot_detection = 15
@export var worker_robot_speed = 10
@export var worker_robot_cost = 30
@export var worker_robot_production = 10.0



@export var resources_mined = 100 # amount a harvest action gives the worker
@export var construction_costs = [0, 400, 500, 150] # the construction costs for different types of buildings
@export var faction_zero_resources = [0,0] # faction 0's balances in the different resources
@export var faction_one_resources = [0,0] # faction 1's balances in the different resources
@export var unit_max = [4, 4] # how many units can a faction currently have at max?
@export var resource = 1000 # how many resources can be mined
@export var faction_zero_resource_limits = [1000, 0] # faction 0's maximum capacity of the different resources
@export var faction_one_resource_limits = [1000, 0] # faction 1's maximum capacity of the different resources
@export var upgrade_cost = 400 # cost to by the upgrade

@export var building_hp = 110 # health for building
@export var building_spawn_delay = 1 # delay when units are spawned
@export var building_unit_capacity = 4 # limit for units on barrack

@export var housing_hp = 130
@export var housing_resource_cap_a = 500 # limit for resouce 0
@export var housing_resource_cap_b = 500 # limit for resouce 1

@export var wall_hp = 100 # hp for wall


@export var hq_spawn_delay = 10.0 # how often will new workers spawn?
@export var worker_limit = 4 # how many workers can spawn at most?
@export var hq_hp = 220 # the hq's maximum hp


@export var cameara_speed = 0.5 # camera sensitivity
@export var camera_zoom_speed = 5 # speed for zooming
@export var camera_zoom_up_limit = 75 # upper limit for cam zoom
@export var camera_zoom_down_limit = 30 # lower limit for cam zoom

func _ready():
	setValues()
	#var save = FileAccess.open(FILE, FileAccess.WRITE)
	#var json_string = JSON.stringify(Global.unit_dict)
	#save.store_line(json_string)

func reset():
	faction_one_resources = [0,0]
	faction_zero_resources = [0,0]
	upgrade1 = [false, false]
	unit_max = [4, 4]
	faction_zero_resource_limits = [1000, 0]
	faction_one_resource_limits = [1000, 0]
	Global.resetVariables()

# sets the values of the dictionary to be the same as balance editor
func setValues():
	Global.unit_dict["0"]["max_hp"] = titan_hp
	Global.unit_dict["0"]["damage_value"] = titan_damage
	Global.unit_dict["0"]["attack_range"] = titan_range
	Global.unit_dict["0"]["attack_speed"] = titan_attack_speed
	Global.unit_dict["0"]["detection_range"] = titan_detection
	Global.unit_dict["0"]["speed"] = titan_speed
	Global.unit_dict["0"]["resource_cost"] = titan_cost
	Global.unit_dict["0"]["production_speed"] = titan_production
	
	Global.unit_dict["1"]["max_hp"] = runner_hp
	Global.unit_dict["1"]["damage_value"] = runner_damage
	Global.unit_dict["1"]["attack_range"] = runner_range
	Global.unit_dict["1"]["attack_speed"] = runner_attack_speed
	Global.unit_dict["1"]["detection_range"] = runner_detection
	Global.unit_dict["1"]["speed"] = runner_speed
	Global.unit_dict["1"]["resource_cost"] = runner_cost
	Global.unit_dict["1"]["production_speed"] = runner_production
	
	Global.unit_dict["2"]["max_hp"] = sentinel_hp
	Global.unit_dict["2"]["damage_value"] = sentinel_damage
	Global.unit_dict["2"]["attack_range"] = sentinel_range
	Global.unit_dict["2"]["attack_speed"] = sentinel_attack_speed
	Global.unit_dict["2"]["detection_range"] = sentinel_detection
	Global.unit_dict["2"]["speed"] = sentinel_speed
	Global.unit_dict["2"]["resource_cost"] = sentinel_cost
	Global.unit_dict["2"]["production_speed"] = sentinel_production
	
	Global.unit_dict["worker"]["max_hp"] = worker_hp
	Global.unit_dict["worker"]["damage_value"] = worker_damage
	Global.unit_dict["worker"]["attack_range"] = worker_range
	Global.unit_dict["worker"]["attack_speed"] = worker_attack_speed
	Global.unit_dict["worker"]["detection_range"] = worker_detection
	Global.unit_dict["worker"]["speed"] = worker_speed
	Global.unit_dict["worker"]["resource_cost"] = worker_cost
	Global.unit_dict["worker"]["production_speed"] = worker_production
	
	Global.unit_dict["worker_robot"]["max_hp"] = worker_robot_hp
	Global.unit_dict["worker_robot"]["damage_value"] = worker_robot_damage
	Global.unit_dict["worker_robot"]["attack_range"] = worker_robot_range
	Global.unit_dict["worker_robot"]["attack_speed"] = worker_robot_attack_speed
	Global.unit_dict["worker_robot"]["detection_range"] = worker_robot_detection
	Global.unit_dict["worker_robot"]["speed"] = worker_robot_speed
	Global.unit_dict["worker_robot"]["resource_cost"] = worker_robot_cost
	Global.unit_dict["worker_robot"]["production_speed"] = worker_robot_production

