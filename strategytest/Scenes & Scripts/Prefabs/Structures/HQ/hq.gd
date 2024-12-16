extends Node3D

signal new_worker(worker) # to tell the system a new worker has spawned
signal destruction(faction) # to trigger the game end screen

const TARGET_TYPE = "hq" # the hq's target type
const SPAWN_DELAY = 10.0 # how often will new workers spawn?
const MAX_WORKERS = 4 # how many workers can spawn at most?
const MAX_HP = 20.0 # the hq's maximum hp

var current_workers = 0 # how many workers are currently alive?
var can_spawn = false # can the hq spawn a new worker?

@onready var unit_manager = $".."/Units
@onready var hp = Balance.hq_hp # the hq's current hp, initially set to the maximum

@export var faction = 0 # the hq's faction

# called at the start of the game
func _ready():
	$HqBody.set_surface_override_material(3, load(Global.getFactionColor(faction))) 
	$HealthbarContainer/HealthBar.max_value = MAX_HP # adjusts the health bar display to this unit's maximum hp
	$HealthbarContainer/HealthBar.value = hp
	$SpawnTimer.start(Balance.hq_spawn_delay) # prepares to spawn the first worker

# checks repeatedly to spawn new workers
func _process(_delta):
	var spawn_point = getEmptySpawn()
	if spawn_point != null and can_spawn and current_workers < Balance.worker_limit:
		spawnWorker(spawn_point) # spawns a new worker if a spawn is available and the number of workers has not yet reached the cap

	for i in Global.list:#iterates through the list
		if Global.list[i]["worker"] != null:
			var worker_id = Global.list[i]["worker"] #gets the worker node
			Global.list[i]["positionX"] = worker_id.global_position.x # updates the position x in dictionary 
			Global.list[i]["positionY"] = worker_id.global_position.z # updates the position y in dictionary 

# spawns a new worker
func spawnWorker(spawn_point):
	can_spawn = false # makes further spawns unavailable
	$SpawnTimer.start(Balance.hq_spawn_delay) # starts the delay for the next spawn
	current_workers += 1 # saves the new number of workers
	
	var worker = load("res://Scenes & Scripts/Prefabs/Units/Worker/worker.tscn").instantiate() # instantiates a new worker object
	$Workers.add_child(worker) # adds the worker to the correct node
	worker.global_position = spawn_point # moves the worker to the correct spawn location
	worker.setUp("worker")
	worker.setFaction(faction) # assigns the worker to the hq's faction
	worker.hq = self # saves the hq's position on the worker
	worker.deleted.connect(_on_worker_deleted)
	# add a new entry to the dictionary when a worker spawns
	Global.add_to_list(worker.global_position.x, worker.global_position.z, faction, worker.get_instance_id(), null, worker)
	if faction == Global.player_faction:
		new_worker.emit(worker)
	else:
		worker.visible = false

func clearUnitReferences(unit):
	for worker in $Workers.get_children():
		worker.checkUnitRemoval(unit)

# removes references to an expended resource from the workers
func excludeResource(node):
	for worker in $Workers.get_children():
		worker.removeResourceKnowledge(node) # calls the requisite function on each worker

# causes the hq to take a given amount of damage
func takeDamage(damage, _attacker):
	hp -= damage # subtracts the damage taken from the current hp
	$HealthBarSprite.visible = true
	$HealthbarContainer/HealthBar.value = hp # updates the health bar display
	if hp <= 0: # removes the hq if it's remaining hp is 0 or less
		destruction.emit(faction) # notifies that the game has ended
		queue_free() # then deletes the hq

# checks for an empty spawn point
func getEmptySpawn():
	for point in $SpawnPoints.get_children():
		if !point.has_overlapping_bodies():
			return point.global_position # if a spawn point is empty (no other unit is occupying it), return that spawn point
	return null # if there are no empty spawn points, returns null instead

# returns an array of the ressources near the HQ
func getResources():
	var nearby = $DetectionArea.get_overlapping_bodies() # checks for all nearby bodies
	var resources = []
	for body in nearby:
		if body.is_in_group("resource"):
			resources.append(body) # adds all ressources in that list to an array
	return resources # returns the array

# returns the faction the HQ belongs to
func getFaction():
	return faction

# returns the target type (hq)
func getType():
	return TARGET_TYPE

# returns the HQ's physical size
func getSize():
	return ($HqSize.mesh.size.x / 2)
	#added a Mesh for size measurement because no index on arraymesh

# returns the HQ's detection area
func getArea():
	return $DetectionArea

# returns the HQ's worker storage
func getWorkers():
	return $Workers

# returns the hq's number of current workers out of the maximum number of workers
func getWorkerNum():
	return str(current_workers) + "/" + str(Balance.worker_limit)

func updateVisibility(object):
	if !visible:
		visible = true

# clears remaining references to a deleted worker
func _on_worker_deleted(worker):
	current_workers -= 1 # subtracts the removed worker from the current amount
	unit_manager._on_unit_delete(worker) # calls to remove all other references

# makes a new worker spawn available when the spawn delay ends
func _on_spawn_timer_timeout():
	can_spawn = true
