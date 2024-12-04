extends Control
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

@export var worker_hp = 2.0 # the worker's maximum hit points
@export var worker_speed = 10.0 # the worker's movement speed
@export var resources_mined = 1 # the worker's capacity of resources 


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
@export var resource = 10 # how many resources can be mined

# text to be translated
# title in faction selection
# faction buttons
# Gamestateinfo
# building tab
# unit type buttons
# Game Over screen
# Quit button
