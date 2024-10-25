extends Node3D

const UNIT_COST = 1 # how many crystals does each unit from this building cost to produce?
const SPAWN_RATE = 5.0 # how often can the building produce new units?
var can_spawn = false # can the building currently produce a new unit?

var hp = 4 # the building's current hit points

@onready var unit_storage = $"../Units" # the main system node for units

# prepares to spawn a new unit when first built
func _ready():
	$SpawnTimer.start(SPAWN_RATE)

# checks repeatedly if a new unit can be spawned
func _process(delta):
	if can_spawn and Global.crystals >= UNIT_COST:
		spawnUnit() # spawns a new unit if the building is able to, and the player has the crystals required

# spawns a new unit
func spawnUnit():
	can_spawn = false # temporarily disables new spawns
	Global.crystals -= UNIT_COST # subtracts the unit's crystal cost from the player's balance
	$SpawnTimer.start(SPAWN_RATE) # starts spawn delay
	
	var new_unit = load("res://units/unit.tscn").instantiate() # instantiates the unit
	unit_storage.add_child(new_unit) # adds the unit to the correct node
	new_unit.global_position = $SpawnPoint.global_position # moves the unit to the correct spawn position

# makes a new spawn available once the delay expires
func _on_spawn_timer_timeout():
	can_spawn = true
