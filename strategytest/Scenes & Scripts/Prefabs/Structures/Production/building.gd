extends Node3D

signal building_menu(building) # to activate the interface when the building is clicked
signal interface_update() # to update the building's interface display

const DISPLAY_NAME = "@name_building_barracks" # the building's displayed name
const TARGET_TYPE = "building" # the building's combat type
const MAX_HP = 8.0 # the building's maximum hit points
const UNIT_CAPACITY = 4 # how many units does this building allow for the player to train in total?

var spawn_queued = false # is a combat unit currently queued to be spawned?
var spawn_active = true # is the building's unit production toggled on?
var faction : int # the faction the building belongs to
var production_type = 0 # which type of unit does the building currently produce?
var unit_cost : int # how many crystals does each unit from this building cost to produce?
var spawn_rate : float # how often can the building produce new units?
var nearby_observers = [] # the nearby enemy units currently observing the building

@onready var greystate = preload("res://Assets/Materials/material_grey_out.tres")
@onready var hp = Balance.building_hp # the building's current hit points, initially set to the maximum hit points
@onready var unit_storage = $"../Units" # the main system node for units

# prepares to spawn a new unit when first built
func _ready():
	$HealthbarContainer/HealthBar.max_value = Balance.building_hp # adjusts the health bar display to this unit's maximum hp
	$HealthbarContainer/HealthBar.value = hp
	$SpawnTimer.stop()
	
	setProductionType(production_type) # sets up the building's unit production

# checks repeatedly if a new unit can be spawned
func _physics_process(_delta):
	Global.healthbar_rotation($HealthBarSprite)
	Global.healthbar_rotation($ProgressSprite)
	
	# if a combat unit is queued to be spawned
	if spawn_queued:
		var spawn_point = getEmptySpawn()
		if spawn_point != null:
			spawn_queued = false
			spawnUnit(spawn_point) # spawns the unit if there is an empty spawn point
			Global.updateQueuedUnitCount(faction, -1) # removes the unit from the global queue
	
	# if no spawn is queued, and no unit is currently being produced
	if $SpawnTimer.is_stopped() and !spawn_queued:
		# queues a new spawn if the player has enough resouces, has room for more units, and the building is toggled on
		if spawn_active and Global.getFullUnitCount(faction) < Global.getUnitLimit(faction) and Global.getResource(faction, 1) >= unit_cost:
			Global.updateResource(faction, 1, -unit_cost) # immediately removes the cost
			startProductionTimer()
	
	# updates the production progress bar otherwise
	elif !$SpawnTimer.is_stopped():
		$ProductionProgress/ProductionBar.value = $SpawnTimer.time_left

	for i in Global.list: #iterates through the list
		if Global.list[i]["worker"] != null:
			var worker_id = Global.list[i]["worker"] #gets the worker node
			Global.list[i]["positionX"] = worker_id.global_position.x #updates the position x in dictionary 
			Global.list[i]["positionY"] = worker_id.global_position.z#updates the position y in dictionary 

# spawns a new unit
func spawnUnit(spawn_point):
	Global.updateUnitCount(faction, 1)
	var new_unit = load("res://Scenes & Scripts/Prefabs/Units/Combat Unit/unit.tscn").instantiate() # instantiates the unit
	unit_storage.add_child(new_unit) # adds the unit to the correct node
	new_unit.global_position = spawn_point # moves the unit to the correct spawn position
	new_unit.setUp(production_type) # sets up the unit's properties based on the building's production type
	new_unit.setFaction(faction) # assigns the spawned unit to the building's faction

	
	if faction != Global.player_faction:
		new_unit.visible = false
	
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
			Global.updateUnitLimit(faction, -UNIT_CAPACITY)
		queue_free() # then deletes the building
	interface_update.emit() # calls to update the interface with the new health value

# returns the building's current hit points
func getHP():
	return hp

# returns the building's maximum hit points
func getMaxHP():
	return Balance.building_hp

# returns the building's display name id
func getDisplayName():
	return DISPLAY_NAME

# accesses the building's interface function
func accessStructure():
	building_menu.emit(self)

# toggles the building's production status
func toggleStatus():
	spawn_active = !spawn_active
	if !spawn_active:
		if !$SpawnTimer.is_stopped():
			$SpawnTimer.stop()
			$ProgressSprite.visible = false
			Global.updateResource(faction, 1, int(ceil(float(unit_cost) / 2)))
			Global.updateQueuedUnitCount(faction, -1)

# starts the production of a new unit
func startProductionTimer():
	# sets up the timer bar
	$ProductionProgress/ProductionBar.max_value = spawn_rate
	$ProductionProgress/ProductionBar.value = spawn_rate
	$ProgressSprite.visible = true
	$SpawnTimer.start(spawn_rate)
	Global.updateQueuedUnitCount(faction, 1) # queues the in-production unit
	interface_update.emit()

# sets the building's unit production type
func setProductionType(type):
	if spawn_active:
		# cancels the active production, if it is
		if !$SpawnTimer.is_stopped():
			$SpawnTimer.stop()
			$ProgressSprite.visible = false
			Global.updateResource(faction, 1, int(ceil(float(unit_cost) / 2))) # refunds half the production cost, rounded up
			Global.updateQueuedUnitCount(faction, -1) # removes the unit from the queue
	
	production_type = type
	unit_cost = Global.unit_dict[str(type)]["resource_cost"] # sets the production variables
	spawn_rate = Global.unit_dict[str(type)]["production_speed"]

# sets the building's faction to a given value
func setFaction(f : int):
	faction = f # sets the faction
	$BuildingBody.material_override = load(Global.getFactionColor(faction)) # sets the correct building color
	if faction == 0: # when faction is 0
		$OLBarracks.visible = true # outlaw asset becomes visible
		$BuildingColl.disabled = true
		$NLBarracksCollMain.disabled = true
		$NLBarracksCollMain2.disabled = true
		$NLBarracksFence.disabled = true
		$NLBarracksFence2.disabled = true
		$NLBarracksFence3.disabled = true
		$NLBarracksFence4.disabled = true
		$NLBarracksFence5.disabled = true
		get_parent().bake_navigation_mesh() # rebakes the navmesh when spawned
	elif faction == 1: # when faction is 1
		$NLBarracks.visible = true # new lights assets becomes visible
		$OLBarracksCollMain.disabled = true
		$OLBarracksCollFence1.disabled = true
		$OLBarracksCollFence2.disabled = true
		$OLBarracksCollFence3.disabled = true
		$OLBarracksCollFence4.disabled = true
		$OLBarracksCollFence5.disabled = true
		$OLBarracksCollFence6.disabled = true
		
		
		get_parent().bake_navigation_mesh() # rebakes the navmesh when spawned
	Global.updateUnitLimit(faction, UNIT_CAPACITY)

# returns the building's current faction
func getFaction():
	return faction

# returns the target type (building)
func getType():
	return TARGET_TYPE

# returns the building's function status
func getInspectInfo(info):
	match info:
		"status":
			if !$SpawnTimer.is_stopped():
				return "production"
			elif spawn_active:
				return "active"
			else:
				return "inactive"

# returns the building's current unit production
func getProduction():
	return production_type

# returns the physical size of the building
func getSize():
	return ($BuildingBody.mesh.size.x / 2)

# removes a given unit from the list of the building's observers
func clearUnitReferences(unit):
	fowExit(unit)

# called when the building comes into view of a player-controlled unit
func fowEnter(node):
	if node.getFaction() != faction:
		nearby_observers.append(node)
		fowReveal(true) # enables the visibility of the building
		setGreystate(false) # dusables the greystate of the building

# called when the building is no longer in view of a player-controlled unit
func fowExit(node):
	if nearby_observers.has(node):
		nearby_observers.erase(node)
		if nearby_observers.size() == 0:
			setGreystate(true) # enables the greystate of the building

# sets the visibility of the building to a given state
func fowReveal(bol):
	if visible != bol:
		visible = bol

# sets the greystate of the building
func setGreystate(bol):
	if bol:
		$BuildingBody.material_overlay = greystate
	else:
		$BuildingBody.material_overlay = null

# attempts to spawn a new unit once the timer expires
func _on_spawn_timer_timeout():
	$ProgressSprite.visible = false
	var spawn_point = getEmptySpawn()
	if spawn_point != null:
		spawnUnit(spawn_point) # spawns the unit if there is an empty spawn point
		Global.updateQueuedUnitCount(faction, -1) # removes the unit from the global queue
	else:
		spawn_queued = true # otherwise, queues up a later spawn
	$SpawnTimer.stop()
	interface_update.emit()

# when another object comes near the building
func _on_area_3d_body_entered(body): # function to upgrade units when entered
	if body.is_in_group("Fighter") and body.faction == Global.player_faction: # when global var is active and unit is a combatunit
		body.update_stats() # calls the upgrade function
