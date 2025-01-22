extends Node3D

signal new_worker(worker) # to tell the system a new worker has spawned
signal destruction(faction) # to trigger the game end screen
signal building_menu(hq) # to activate the interface when the building is clicked
signal interface_update() # to update the interface while the HQ is selected

const TARGET_TYPE = "hq" # the hq's target type
const MAX_WORKERS = 4 # how many workers can spawn at most?
const MAX_HP = 20.0 # the hq's maximum hp
const DISPLAY_NAME = "@name_building_hq" # the HQ's name tag

var current_workers = 0 # how many workers are currently alive?
var spawn_active = true # is the HQ's worker production toggled on?
var spawn_queued = false # is a worker currently queued to be spawned?
var spawn_delay : float # the workers' spawn timer
var spawn_cost : int # the workers' resource cost
var detection_range = 50.0 # the range at which the HQ can detect enemy units
var nearby_observers = [] # a list of enemy units near the HQ

@onready var greystate = preload("res://Assets/Materials/material_grey_out.tres")
@onready var unit_manager = $".."/Units # the parent node managing the game's combat units
@onready var hp = Balance.hq_hp # the hq's current hp, initially set to the maximum
@onready var max_hp = Balance.hq_hp # the hq´s max hp

@export var faction = 0 # the hq's faction

# called at the start of the game
func _ready():
	if faction == 0: #  when faction is 0 the outlaw assets will be used
		$OLBaseBody.visible = true
		$HqBody.visible = false
		$HqColl.disabled = true
	else: #  when faction is 1 the ashfolk assets will be used
		$OLBaseBody.visible = false
		$OLHQColl.disabled = true
	$HqBody.set_surface_override_material(3, load(Global.getFactionColor(faction))) 
	$HealthbarContainer/HealthBar.max_value = max_hp # adjusts the health bar display to this unit's maximum hp
	$HealthbarContainer/HealthBar.value = hp
	
	# grabs the worker spawning parameters from the Global data and starts the spawn timer
	spawn_delay = Global.unit_dict["worker"]["production_speed"]
	spawn_cost = Global.unit_dict["worker"]["resource_cost"]

# called on every physics frame
func _physics_process(delta):
	Global.healthbar_rotation($HealthBarSprite)
	Global.healthbar_rotation($ProgressSprite)
	# if a worker is queued to be spawned
	if spawn_queued:
		var spawn_point = getEmptySpawn()
		if spawn_point != null:
			spawn_queued = false
			spawnWorker(spawn_point) # spawns the worker if there is an empty spawn point
	
	# if no worker is queued, and no worker is currently in production
	if $SpawnTimer.is_stopped() and !spawn_queued:
		# starts a new worker production if the building is toggled on, there is room for additional workers, and the player has enough resources
		if spawn_active and current_workers < Balance.worker_limit and Global.getResource(faction, 0) >= spawn_cost:
			Global.updateResource(faction, 0, -spawn_cost) # immediately removes the requisite resources
			startProductionTimer()
	
	# otherwise updates the production progress timer
	elif !$SpawnTimer.is_stopped():
		$ProgressbarContainer/ProgressBar.value = $SpawnTimer.time_left

	for i in Global.list: #iterates through the list
		if Global.list[i]["worker"] != null:
			var worker_id = Global.list[i]["worker"] #gets the worker node
			Global.list[i]["positionX"] = worker_id.global_position.x # updates the position x in dictionary 
			Global.list[i]["positionY"] = worker_id.global_position.z # updates the position y in dictionary 

# spawns a new worker
func spawnWorker(spawn_point):
	current_workers += 1 # saves the new number of workers
	
	var worker = load("res://Scenes & Scripts/Prefabs/Units/Worker/worker.tscn").instantiate() # instantiates a new worker object
	$Workers.add_child(worker) # adds the worker to the correct node
	worker.global_position = spawn_point # moves the worker to the correct spawn location
	worker.setFaction(faction) # assigns the worker to the hq's faction
	if faction == 0:
		worker.setUp("worker")
	elif faction == 1:
		worker.setUp("worker_robot")
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
	Sound.under_Attack()
	if hp <= 0: # removes the hq if it's remaining hp is 0 or less
		destruction.emit(faction) # notifies that the game has ended
		queue_free() # then deletes the hq
	interface_update.emit()

# returns the HQ's current HP
func getHP():
	return hp

# returns the HQ's maximum HP
func getMaxHP():
	return max_hp

# returns the HQ's name id
func getDisplayName():
	return DISPLAY_NAME

# toggles the HQ's production status
func toggleStatus():
	spawn_active = !spawn_active
	if !spawn_active:
		# stops worker production if a worker is currently in production
		if !$SpawnTimer.is_stopped():
			$SpawnTimer.stop()
			$ProgressSprite.visible = false
			Global.updateResource(faction, 0, int(ceil(float(spawn_cost) / 2))) # refunds half of the worker's production cost, rounded up

# returns information about the HQ's current state
func getInspectInfo(info):
	match info:
		# returns information about the HQ's status
		"status":
			if !$SpawnTimer.is_stopped():
				return "production"
			elif spawn_active:
				return "active" # returns "active" if the HQ is currently actively producing workers
			else:
				return "inactive" # returns "inactive" otherwise, if the HQ's production is idle
	return ""

# spawns two initial workers for the player at the start of the game
func spawnStartingWorkers():
	spawnWorker($SpawnPoints.get_children()[0].global_position)
	spawnWorker($SpawnPoints.get_children()[1].global_position)
	if faction == Global.player_faction:
		spawn_active = false # then disables further worker production from the player's HQ

# starts the production of a new worker
func startProductionTimer():
	$ProgressbarContainer/ProgressBar.max_value = spawn_delay
	$ProgressbarContainer/ProgressBar.value = spawn_delay
	$ProgressSprite.visible = true
	$SpawnTimer.start(spawn_delay)
	interface_update.emit()

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

# returns the HQ's detection range
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

# spawns a new worker once the timer expires
func _on_spawn_timer_timeout():
	$ProgressSprite.visible = false
	var spawn_point = getEmptySpawn()
	if spawn_point != null:
		spawnWorker(spawn_point) # attempts to spawn a new worker, if there is an empty spawn point
	else:
		spawn_queued = true # otherwise, queues the worker up to be spawned later on
	$SpawnTimer.stop()
	interface_update.emit()

func doom(): # funtion to kill the hq for the doom ending
	takeDamage(9999, $Workers)
	
