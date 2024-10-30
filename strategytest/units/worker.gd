extends CharacterBody3D

signal deleted(worker) # to tell the system that the worker has been removed

const TARGET_TYPE = "worker" # the worker's combat type
const SPEED = 10.0 # the worker's movement speed
const MAX_HP = 2.0 # the worker's maximum hit points

var SR
var faction = 0 # which faction does the worker belong to?
var path = [] # the navigation path the worker is traveling on
var path_ind = 0 # the index of the worker's current path node
var crystal = 0 # how many crystals the worker is holding
var known_resources = [] # an array of all resource nodes the worker has discovered
var target_resource # the resource the worker is currently moving towards
var priority_movement = false # is the worker's currently overwritten by a player input?
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") # the gravity affecting the worker

@onready var hp = MAX_HP # the worker's current hit points, set to the maximum on instantiation
@onready var go_to = global_position # the worker's current navigation destination
@onready var navi : NavigationAgent3D = $NavAgent # the navigation agent controlling the worker's movement
@onready var hq = $".." # the hq the worker belongs to

# called when the worker is first instantiated
func _ready():
	$HealthbarContainer/HealthBar.max_value = MAX_HP # adjusts the health bar display to this unit's maximum hp
	$HealthbarContainer/HealthBar.value = hp

# controls the worker's movement and other actions
func _physics_process(delta):
	# applies gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# checks where the worker should move if their movement isn't overwritten by the player
	if !priority_movement:
		# if the worker has a crystal
		if crystal != 0:
			# if the worker is near the hq
			if global_position.distance_to(hq.global_position) < 6:
				Global.addCrystals(crystal, faction) # adds crystal to player's resources
				crystal = 0
			# if the worker is further away from the hq
			else:
				go_to = hq.global_position # sets hq as movement destination
		
		# if the worker has no crystal, but a movement destination
		elif target_resource != null:
			# if the worker is near the destination resource
			if global_position.distance_to(target_resource.global_position) <= 3:
				target_resource.get_parent().get_parent().takeResource() # removes a resource from that node
				crystal = 1 # adds the crystal to the worker
				target_resource = null # clears the worker's target's resource
			# if the worker is further away from the destination
			else:
				go_to = target_resource.global_position # sets movement destination
		
		# if the worker has no crystal and no movement destination
		else:
			var closest_distance
			var closest_resource
			# checks through all known resources
			for res in known_resources:
				# checks if a resource reference is still valid (if it hasn't been cleared from the list yet)
				if is_instance_valid(res):
					# if this is the first resource, or its closer than the previously saved resource, saves it in the temporary variables
					if closest_distance == null or global_position.distance_to(res.global_position) < closest_distance:
						closest_distance = global_position.distance_to(res.global_position)
						closest_resource = res
			if closest_resource != null:
				target_resource = closest_resource # sets a new target resource if any was saved in the temporary variables
	
	# controls the unit's actual movement
	if go_to != global_position:
		navi.target_position = go_to
		var dir = navi.get_next_path_position() - global_position
		dir = dir.normalized()
	
		velocity = velocity.lerp(dir * SPEED, 10 * delta)
		if global_position.distance_to(go_to) < 2:
			velocity = Vector3.ZERO
			go_to = global_position
			priority_movement = false
		move_and_slide()

# receives the path from NavAgent
func move_to(target_pos):
	path = navi.get_simple_path(global_transform.origin, target_pos)
	path_ind = 0

# causes the worker to take a given amount of damage
func takeDamage(damage, attacker):
	hp -= damage # subtracts the damage taken from the current hp
	$HealthBarSprite.visible = true
	$HealthbarContainer/HealthBar.value = hp # updates the health bar display
	if hp <= 0: # removes the worker if it's remaining hp is 0 or less
		deleted.emit(self) # tells the system to clear remaining references to the worker
		queue_free() # then deletes the worker

# sets attack target (has no effect for the worker)
func setAttackTarget(unit):
	pass

# sets the worker's faction to a given value
func setFaction(f : int):
	faction = f
	$WorkerBody.material_override = load(Global.getFactionColor(faction))

# returns the worker's current faction
func getFaction():
	return faction

# returns the combat target type (worker)
func getType():
	return TARGET_TYPE

func getSize():
	return $WorkerColl.shape.radius

func isWorking():
	if known_resources.size() > 0 or crystal > 0 or priority_movement:
		return true
	else:
		return false

# changes the color of the unit when selected or deselected
func select():
	$WorkerBody.material_override = load("res://units/material_friendly_selected.tres")

func deselect():
	$WorkerBody.material_override = load("res://units/material_friendly.tres")

# sets the position the NavAgent will move to
func setTargetPosition(target):
	target_resource = null
	priority_movement = true
	go_to = target

# removes a cleared resource node from the worker's list if it is on there
func removeResourceKnowledge(resource):
	if known_resources.has(resource):
		known_resources.erase(resource)

# if a new resource entered the worker's detection radius, adds it to its list
func _on_range_area_body_entered(body):
	if body.is_in_group("resource") and !known_resources.has(body):
		known_resources.append(body)
