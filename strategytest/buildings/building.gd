extends Node3D

const TARGET_TYPE = "building" # the building's combat type
const MAX_HP = 8.0 # the building's maximum hit points
const UNIT_COST = 0 # how many crystals does each unit from this building cost to produce?
const SPAWN_RATE = 5.0 # how often can the building produce new units?
var can_spawn = false # can the building currently produce a new unit?
var spawn_active = false # is the building's unit production toggled on?
var faction = 0 # the faction the building belongs to

@onready var hp = MAX_HP # the building's current hit points, initially set to the maximum hit points
@onready var unit_storage = $"../Units" # the main system node for units

# prepares to spawn a new unit when first built
func _ready():
	$HealthbarContainer/HealthBar.max_value = MAX_HP # adjusts the health bar display to this unit's maximum hp
	$HealthbarContainer/HealthBar.value = hp
	$SpawnTimer.start(SPAWN_RATE)

# checks repeatedly if a new unit can be spawned
func _process(delta):
	var spawn_point = getEmptySpawn()
	if can_spawn and spawn_active and spawn_point != null and Global.getCrystals(faction) >= UNIT_COST:
		spawnUnit(spawn_point) # spawns a new unit if the building is able to, and the player has the crystals required
	for i in Global.list_soldiers:#iterates through the list
		var soldier_id = Global.list_soldiers[i]["soldier"] #gets the worker node
		Global.list_soldiers[i]["positionX"] = soldier_id.global_position.x #updates the position x in dictionary 
		Global.list_soldiers[i]["positionY"] = soldier_id.global_position.z#updates the position y in dictionary 



# spawns a new unit
func spawnUnit(spawn_point):
	can_spawn = false # temporarily disables new spawns
	Global.addCrystals(-UNIT_COST, faction) # subtracts the unit's crystal cost from the player's balance
	$SpawnTimer.start(SPAWN_RATE) # starts spawn delay
	
	
	
	var new_unit = load("res://units/unit.tscn").instantiate() # instantiates the unit
	unit_storage.add_child(new_unit) # adds the unit to the correct node
	new_unit.global_position = spawn_point # moves the unit to the correct spawn position
	new_unit.setFaction(faction) # assigns the spawned unit to the building's faction
	unit_storage.connectDeletion(new_unit) # calls for the storage to connect to its new child
	#add a new entry to the dictionary when a worker spawns
	Global.add_to_list_soldiers(new_unit.global_position.x, new_unit.global_position.z, faction, new_unit.get_instance_id(), null , new_unit)

# checks for an empty spawn point
func getEmptySpawn():
	for point in $SpawnPoints.get_children():
		if !point.has_overlapping_bodies():
			return point.global_position # if a spawn point is empty (no other unit is occupying it), return that spawn point
	return null # if there are no empty spawn points, returns null instead

# causes the building to take a given amount of damage
func takeDamage(damage, attacker):
	hp -= damage # subtracts the damage taken from the current hp
	$HealthBarSprite.visible = true
	$HealthbarContainer/HealthBar.value = hp # updates the health bar display
	if hp <= 0: # removes the building if it's remaining hp is 0 or less
		queue_free() # then deletes the building

# accesses the building's function
func accessStructure():
	spawn_active = !spawn_active # toggle's spawn from this building
	$BuildingPause.visible = !spawn_active # sets the visibility of the pause animation appropriately

# sets the building's faction to a given value
func setFaction(f : int):
	faction = f # sets the faction
	$BuildingBody.material_override = load(Global.getFactionColor(faction)) # sets the correct building color

# returns the building's current faction
func getFaction():
	return faction

# returns the target type (building)
func getType():
	return TARGET_TYPE

# returns the physical size of the building
func getSize():
	return ($BuildingBody.mesh.size.x / 2)

# makes a new spawn available once the delay expires
func _on_spawn_timer_timeout():
	can_spawn = true
