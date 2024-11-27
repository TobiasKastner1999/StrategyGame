extends Node3D


signal building_menu(building) # to activate the interface when the building is clicked
signal interface_update() # to update the building's interface display
signal destroyed()

const DISPLAY_NAME = "Building" # the building's displayed name
const TARGET_TYPE = "building" # the building's combat type
const MAX_HP = 8.0 # the building's maximum hit points

var can_spawn = false # can the building currently produce a new unit?
var spawn_active = true # is the building's unit production toggled on?
var faction : int # the faction the building belongs to
var production_type = 0 # which type of unit does the building currently produce?
var unit_cost : int # how many crystals does each unit from this building cost to produce?
var spawn_rate : float # how often can the building produce new units?


@onready var hp = MAX_HP # the building's current hit points, initially set to the maximum hit points
@onready var unit_storage = $"../Units" # the main system node for units

# prepares to spawn a new unit when first built
func _ready():
	$HealthbarContainer/HealthBar.max_value = MAX_HP # adjusts the health bar display to this unit's maximum hp
	$HealthbarContainer/HealthBar.value = hp
	
	setProductionType(production_type) # sets up the building's unit production

func _process(delta):
	pass

# checks repeatedly if a new unit can be spawned
func _physics_process(_delta):
	var spawn_point = getEmptySpawn()
	if can_spawn and spawn_active and spawn_point != null and Global.getResource(faction, 1) >= unit_cost and Global.getUnitCount(faction) < Global.getUnitLimit(faction):
		spawnUnit(spawn_point) # spawns a new unit if the building is able to, and the player has the crystals required

	for i in Global.list:#iterates through the list
		if Global.list[i]["worker"] != null:
			var worker_id = Global.list[i]["worker"] #gets the worker node
			Global.list[i]["positionX"] = worker_id.global_position.x #updates the position x in dictionary 
			Global.list[i]["positionY"] = worker_id.global_position.z#updates the position y in dictionary 
	
	$ProductionProgress/ProductionBar.value = $SpawnTimer.time_left
	if $SpawnTimer.time_left == 0:
		$ProgressSprite.visible = false


# spawns a new unit
func spawnUnit(spawn_point):
	can_spawn = false # temporarily disables new spawns
	Global.updateResource(faction, 1, -unit_cost) # subtracts the unit's crystal cost from the player's balance
	Global.updateUnitCount(faction, 1)
	$SpawnTimer.start(spawn_rate) # starts spawn delay
	$ProgressSprite.visible = true
	var new_unit = load("res://Scenes & Scripts/Prefabs/Units/Combat Unit/unit.tscn").instantiate() # instantiates the unit
	unit_storage.add_child(new_unit) # adds the unit to the correct node
	new_unit.global_position = spawn_point # moves the unit to the correct spawn position
	new_unit.setUp(production_type) # sets up the unit's properties based on the building's production type
	new_unit.setFaction(faction) # assigns the spawned unit to the building's faction
	# add entry to dictionary for combat units
	Global.add_to_list(new_unit.global_position.x, new_unit.global_position.z, faction, new_unit.get_instance_id(), null , new_unit)
	unit_storage.connectDeletion(new_unit) # calls for the storage to connect to its new child

# checks for an empty spawn point
func getEmptySpawn():
	for point in $SpawnPoints.get_children():
		if !point.has_overlapping_bodies():
			return point.global_position # if a spawn point is empty (no other unit is occupying it), return that spawn point
	return null # if there are no empty spawn points, returns null instead

# causes the building to take a given amount of damage
func takeDamage(damage, _attacker):
	hp -= damage # subtracts the damage taken from the current hp
	$HealthBarSprite.visible = true
	$HealthbarContainer/HealthBar.value = hp # updates the health bar display
	if hp <= 0: # removes the building if it's remaining hp is 0 or less
		if faction == Global.player_faction:
			Global.updateBuildingCount(false)
		destroyed.emit(faction)
		queue_free() # then deletes the building
	interface_update.emit() # calls to update the interface with the new health value
	
	
# accesses the building's interface function
func accessStructure():
	building_menu.emit(self)

# toggles the building's production status
func toggleStatus():
	spawn_active = !spawn_active # toggle's spawn from this building
	$BuildingPause.visible = !spawn_active # sets the visibility of the pause animation appropriately

# sets the building's unit production type
func setProductionType(type):
	production_type = type
	unit_cost = Global.unit_dict[str(type)]["resource_cost"] # sets the production variables
	spawn_rate = Global.unit_dict[str(type)]["production_speed"]
	$ProductionProgress/ProductionBar.max_value = spawn_rate
	$ProductionProgress/ProductionBar.value = spawn_rate
	$ProgressSprite.visible = true
	$SpawnTimer.start(spawn_rate) # then (re-)starts the production timer

# sets the building's faction to a given value
func setFaction(f : int):
	faction = f # sets the faction

# returns the building's current faction
func getFaction():
	return faction

# returns the target type (building)
func getType():
	return TARGET_TYPE

# returns the building's function status
func getStatus():
	return spawn_active

# returns the building's current unit production
func getProduction():
	return production_type

# returns the physical size of the building
func getSize():
	return ($BuildingColl.shape.size.x / 2)

# makes a new spawn available once the delay expires
func _on_spawn_timer_timeout():
	can_spawn = true

