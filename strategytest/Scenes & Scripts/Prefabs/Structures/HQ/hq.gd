extends Node3D

signal new_worker(worker) # to tell the system a new worker has spawned
signal destruction(faction) # to trigger the game end screen
signal building_menu(hq) # to activate the interface when the building is clicked
signal interface_update() # to update the interface while the HQ is selected

const TARGET_TYPE = "hq" # the hq's target type
const SPAWN_DELAY = 10.0 # how often will new workers spawn?
const MAX_WORKERS = 4 # how many workers can spawn at most?
const MAX_HP = 20.0 # the hq's maximum hp
const DISPLAY_NAME = "@name_building_hq" # the HQ's name tag

var current_workers = 0 # how many workers are currently alive?
var can_spawn = false # can the hq spawn a new worker?
var detection_range = 50.0 # the range at which the HQ can detect enemy units
var nearby_observers = [] # a list of enemy units near the HQ

@onready var greystate = preload("res://Assets/Materials/material_grey_out.tres")
@onready var unit_manager = $".."/Units # the parent node managing the game's combat units
@onready var hp = Balance.hq_hp # the hq's current hp, initially set to the maximum

@export var faction = 0 # the hq's faction

# called at the start of the game
func _ready():
	if faction == 0:
		$OL_Base_unbaked.visible = true
		$HqBody.visible = false
	else:
		$OL_Base_unbaked.visible = false
		$HqBody.visible = true
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

# clears references to a given unit from the HQ and its workers
func clearUnitReferences(unit):
	fowExit(unit) # removes the unit from the list of the HQ's observers
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
	interface_update.emit()

# returns the HQ's current HP
func getHP():
	return hp

# returns the HQ's maximum HP
func getMaxHP():
	return MAX_HP

# returns the HQ's name id
func getDisplayName():
	return DISPLAY_NAME

# checks for an empty spawn point
func getEmptySpawn():
	for point in $SpawnPoints.get_children():
		if !point.has_overlapping_bodies():
			return point.global_position # if a spawn point is empty (no other unit is occupying it), return that spawn point
	return null # if there are no empty spawn points, returns null instead

# opens the HQ's interface menu
func accessStructure():
	building_menu.emit(self)

# returns an array of the ressources near the HQ
func getResources():
	var nearby = $ResourceDetectionArea.get_overlapping_bodies() # checks for all nearby bodies
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

# returns the HQ's resource detection area
func getArea():
	return $ResourceDetectionArea

# returns the HQ's worker storage
func getWorkers():
	return $Workers

# returns the hq's number of current workers out of the maximum number of workers
func getWorkerNum():
	return str(current_workers) + "/" + str(Balance.worker_limit)

# called when the hq comes into view of a player-controlled unit
func fowEnter(node):
	if node.getFaction() != faction:
		nearby_observers.append(node)
		fowReveal(true) # enables the visibility of the hq
		setGreystate(false) # disables the HQ's greystate

# called when the hq is no longer in view of a player-controlled unit
func fowExit(node):
	if nearby_observers.has(node):
		nearby_observers.erase(node)
		if nearby_observers.size() == 0:
			setGreystate(true) # enables the HQ's greystate

# sets the visibility of the hq to a given state
func fowReveal(bol):
	if visible != bol:
		visible = bol

# sets the greystate of the HQ
func setGreystate(bol):
	if bol:
		$HqBody.material_overlay = greystate
	else:
		$HqBody.material_overlay = null

func getDetectionRange():
	return $UnitDetectionArea/DetectionAreaShape.shape.radius

# when a new object enters the hq's detection range
func _on_unit_detection_body_entered(body):
	if body.is_in_group("FowObject") and faction == Global.player_faction:
		body.fowEnter(self) # triggers the object's fow detection

# when an object leaves the hq's detection range
func _on_unit_detection_body_exited(body):
	if body.is_in_group("FowObject") and faction == Global.player_faction:
		body.fowExit(self) # updates the object's fow detection

# clears remaining references to a deleted worker
func _on_worker_deleted(worker):
	current_workers -= 1 # subtracts the removed worker from the current amount
	unit_manager._on_unit_delete(worker) # calls to remove all other references

# makes a new worker spawn available when the spawn delay ends
func _on_spawn_timer_timeout():
	can_spawn = true
