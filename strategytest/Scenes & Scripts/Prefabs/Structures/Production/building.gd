extends Node3D

signal building_menu(building) # to activate the interface when the building is clicked
signal interface_update() # to update the building's interface display
signal destroyed(building)

const DISPLAY_NAME = "@name_building_barracks" # the building's displayed name
const TARGET_TYPE = "building" # the building's combat type
const MAX_HP = 8.0 # the building's maximum hit points
const UNIT_CAPACITY = 4 # how many units does this building allow for the player to train in total?

var detection_range = 25.0
var spawn_queued = false # is a combat unit currently queued to be spawned?
var spawn_active = true # is the building's unit production toggled on?
var faction : int # the faction the building belongs to
var production_type = 0 # which type of unit does the building currently produce?
var unit_cost : int # how many crystals does each unit from this building cost to produce?
var spawn_rate : float # how often can the building produce new units?
var nearby_observers = [] # the nearby enemy units currently observing the building

@onready var greystate = preload("res://Assets/Materials/material_grey_out.tres") # greystate material for fow
@onready var hp = Balance.building_hp # the building's current hit points, initially set to the maximum hit points
@onready var unit_storage = $"../Units" # the main system node for units

# prepares to spawn a new unit when first built
func _ready():
	toggleStatus() # disables the barracks at the start of the game
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
	new_unit.setFaction(faction) # assigns the spawned unit to the building's faction
	new_unit.setUp(production_type) # sets up the unit's properties based on the building's production type
	
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
	Sound.under_Attack()
	if hp <= 0: # removes the building if it's remaining hp is 0 or less
		Sound.play_sound("res://Sounds/DestroyBuildingSound.mp3", $".")
		await get_tree().create_timer(0.5).timeout
		if faction == Global.player_faction:
			Global.removeKnownTarget(self) # attempts to remove the building from the AI's list of known buildings
			Global.updateBuildingCount(false)
			Global.updateUnitLimit(faction, -UNIT_CAPACITY)
		destroyed.emit(self)
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

# sets the building's production status to a specific value
func setStatus(status):
	spawn_active = status
	if !spawn_active:
		if !$SpawnTimer.is_stopped():
			$SpawnTimer.stop()
			$ProgressSprite.visible = false
			Global.updateResource(faction, 1, int(ceil(float(unit_cost) / 2)))
			Global.updateQueuedUnitCount(faction, -1)

func toggleStatus_on(): # turns the building on only
	spawn_active = !spawn_active

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
	if production_type != type:
		if spawn_active:
			# cancels the active production, if it is
			if !$SpawnTimer.is_stopped():
				$SpawnTimer.stop()
				$ProgressSprite.visible = false
				Global.updateResource(faction, 1, int(ceil(float(unit_cost) / 2))) # refunds half the production cost, rounded up
				Global.updateQueuedUnitCount(faction, -1) # removes the unit from the queue
	
	production_type = type
	unit_cost = Global.unit_dict[str(type)]["resource_cost"] # sets the production variables
	spawn_rate = Global.unit_dict[str(type)]["production_speed"] # sets the time it takes to produce the unit

# sets the building's faction to a given value
func setFaction(f : int):
	faction = f # sets the faction
	if faction == 0: # when faction is 0
		$OLBarracks.visible = true # outlaw asset becomes visible
		$NLBarracksCollMain.disabled = true
		$NLBarracksCollMain2.disabled = true
		#$NLBarracksFence.disabled = true
		#$NLBarracksFence2.disabled = true
		#$NLBarracksFence3.disabled = true
		#$NLBarracksFence4.disabled = true
		#$NLBarracksFence5.disabled = true
	elif faction == 1: # when faction is 1
		$NLBarracks.visible = true # new lights assets becomes visible
		$OLBarracksCollMain.disabled = true
		#$OLBarracksCollFence1.disabled = true
		#$OLBarracksCollFence2.disabled = true
		#$OLBarracksCollFence3.disabled = true
		#$OLBarracksCollFence4.disabled = true
		#$OLBarracksCollFence5.disabled = true
		#$OLBarracksCollFence6.disabled = true
		
	if faction != Global.player_faction:
		toggleStatus_on()
	# sets up the correct initial unit production type
	Global.updateUnitLimit(faction, UNIT_CAPACITY)
	for unit_id in Global.unit_dict.keys():
		if Global.unit_dict[unit_id]["faction"] == faction:
			setProductionType(int(unit_id)) # sets the first unit of the controlled faction as the new production
			return

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
		$OLBarracks.material_overlay = greystate
		$NLBarracks.material_overlay = greystate
	else:
		$OLBarracks.material_overlay = null
		$NLBarracks.material_overlay = null

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

func getIcon():
	if Global.player_faction == 0:
		return load("res://Assets/UI/OL_Kaserne_UI.png")
	else:
		return load("res://Assets/UI/NL_barracks_UI.png")

# when a body enters the building's detection area
func _on_range_area_body_entered(body):
	if body.is_in_group("FowObject") and faction == Global.player_faction:
		body.fowEnter(self) # triggers the object's fow detection

# when a body exits the building's detection area
func _on_range_area_body_exited(body):
	if body.is_in_group("FowObject") and faction == Global.player_faction:
		body.fowExit(self) # updates the object's fow detection
