extends Node3D

const SPAWN_DELAY = 10.0 # how often will new workers spawn?
const MAX_WORKERS = 4 # how many workers can spawn at most?
var current_workers = 0 # how many workers are currently alive?
var can_spawn = false # can the hq spawn a new worker?

@onready var unit_manager = $".."/Units

# called at the start of the game
func _ready():
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
	worker.hq = self # saves the hq's position on the worker
	worker.deleted.connect(_on_worker_deleted)

# clears remaining references to a deleted worker
func _on_worker_deleted(worker):
	current_workers -= 1 # subtracts the removed worker from the current amount
	unit_manager._on_unit_delete(worker) # calls to remove all other references

# makes a new worker spawn available when the spawn delay ends
func _on_spawn_timer_timeout():
	can_spawn = true
