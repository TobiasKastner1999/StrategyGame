extends Node3D

const SPAWN_DELAY = 10.0
const MAX_WORKERS = 4
var current_workers = 0
var can_spawn = false

func _ready():
	$SpawnTimer.start(SPAWN_DELAY)

func _process(delta):
	if can_spawn and current_workers < MAX_WORKERS:
		spawnWorker()

func spawnWorker():
	can_spawn = false
	$SpawnTimer.start(SPAWN_DELAY)
	current_workers += 1
	
	var worker = load("res://units/worker.tscn").instantiate()
	$Workers.add_child(worker)
	worker.global_position = $SpawnPoint.global_position
	worker.hq = self

func _on_spawn_timer_timeout():
	can_spawn = true
