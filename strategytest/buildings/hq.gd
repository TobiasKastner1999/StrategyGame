extends Node3D

const TARGET_TYPE = "hq" # the hq's target type
const SPAWN_DELAY = 10.0 # how often will new workers spawn?
const MAX_WORKERS = 4 # how many workers can spawn at most?
const MAX_HP = 20.0 # the hq's maximum hp

var current_workers = 0 # how many workers are currently alive?
var can_spawn = false # can the hq spawn a new worker?
var unit_manager

@onready var hp = MAX_HP # the hq's current hp, initially set to the maximum

@export var faction = 0

# called at the start of the game
func _ready():
	$HqBody.material_override = load(Global.getFactionColor(faction))
	$HealthbarContainer/HealthBar.max_value = MAX_HP # adjusts the health bar display to this unit's maximum hp
	$HealthbarContainer/HealthBar.value = hp
	$SpawnTimer.start(SPAWN_DELAY) # prepares to spawn the first worker

# checks repeatedly to spawn new workers
func _process(delta):
	if can_spawn and current_workers < MAX_WORKERS:
		spawnWorker() # spawns a new worker if a spawn is available and the number of workers has not yet reached the cap

# spawns a new worker
func spawnWorker():
	can_spawn = false # makes further spawns unavailable
	$SpawnTimer.start(SPAWN_DELAY) # starts the delay for the next spawn
	current_workers += 1 # saves the new number of workers
	
	var worker = load("res://units/worker.tscn").instantiate() # instantiates a new worker object
	$Workers.add_child(worker) # adds the worker to the correct node
	worker.global_position = $SpawnPoint.global_position # moves the worker to the correct spawn location
	worker.setFaction(faction)
	worker.hq = self # saves the hq's position on the worker
	worker.deleted.connect(_on_worker_deleted)

# removes references to an expended resource from the workers
func excludeResource(node):
	for worker in $Workers.get_children():
		worker.removeResourceKnowledge(node) # calls the requisite function on each worker

# causes the hq to take a given amount of damage
func takeDamage(damage, attacker):
	hp -= damage # subtracts the damage taken from the current hp
	$HealthBarSprite.visible = true
	$HealthbarContainer/HealthBar.value = hp # updates the health bar display
	if hp <= 0: # removes the hq if it's remaining hp is 0 or less
		queue_free() # then deletes the hq

# returns the faction the HQ belongs to
func getFaction():
	return faction

# returns the target type (hq)
func getType():
	return TARGET_TYPE

func getSize():
	return ($HqBody.mesh.size.x / 2)

# clears remaining references to a deleted worker
func _on_worker_deleted(worker):
	current_workers -= 1 # subtracts the removed worker from the current amount
	unit_manager._on_unit_delete(worker) # calls to remove all other references

# makes a new worker spawn available when the spawn delay ends
func _on_spawn_timer_timeout():
	can_spawn = true
