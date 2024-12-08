extends CharacterBody3D

signal deleted(worker) # to tell the system that the worker has been removed

const TARGET_TYPE = "worker" # the worker's combat type
const SPEED = 10.0 # the worker's movement speed
const MAX_HP = 2.0 # the worker's maximum hit points
const MINE_SPEED = 5.0 # the speed at which the worker acquired resources
const INTERACTION_STATE_MAX = 2 # the maximum value of the worker's interaction state
const PROXIMITY_DISTANCE = 5.0 # the worker's proximity distance

var SR
var faction = 0 # which faction does the worker belong to?
var interaction_state = 0 # which state of its object interaction is the worker currently in?
var path = [] # the navigation path the worker is traveling on
var path_ind = 0 # the index of the worker's current path node
var resource = [0, 0] # what type of resource is the worker carrying, and how much of it?
var known_resources = [] # an array of all resource nodes the worker has discovered
var priority_movement = false # is the worker's currently overwritten by a player input?
var destination # the worker's current navigation destination
var target_node # the node the worker currently is targeting
var previous_target # the worker's previously targeted resource

@onready var hp = MAX_HP # the worker's current hit points, set to the maximum on instantiation
@onready var navi : NavigationAgent3D = $NavAgent # the navigation agent controlling the worker's movement
@onready var hq = $".." # the hq the worker belongs to

# called when the worker is first instantiated
func _ready():
	$HealthbarContainer/HealthBar.max_value = MAX_HP # adjusts the health bar display to this unit's maximum hp
	$HealthbarContainer/HealthBar.value = hp
	await get_tree().physics_frame
	velocity = Vector3.ZERO

# controls the worker's behaviour
func _physics_process(delta):
	await $UnitBehaviours.runBehaviours(self, delta) # calls the worker's behaviour tree
	animationControl() # then plays the correct animation based on the worker's current state

# controls the worker's animation
func animationControl():
	if interaction_state == 1:
		$rebel_anim/AnimationPlayer.play("attack") # plays the attack animation if the worker is mining
	elif velocity != Vector3.ZERO:
		$rebel_anim/AnimationPlayer.play("walk") # plays the walk animation if they are moving
	else:
		$rebel_anim/AnimationPlayer.play("idle") # plays the idle animation otherwise

# calls the worker to start mining
func startMiningState():
	$MiningTimer.start(MINE_SPEED)
	await get_tree().create_timer(1).timeout
	Sound.play_sound("res://Sounds/MiningSound_Rebells_FreeSoundCommunity.mp3")

# advanced the worker's interaction state
func advanceInteractionState():
	if interaction_state < INTERACTION_STATE_MAX:
		interaction_state += 1 # increments the state if it is not at its max value
	else:
		interaction_state = 0 # resets it otherwise

# returns the worker's current interaction state
func getInteractionState():
	return interaction_state

# checks if the worker is currently doing anything
func isWorking():
	if known_resources.size() > 0 or resource != [0, 0] or priority_movement:
		return true # returns true if the worker is delivering a crystal or knows of any remaining resource nodes
	else:
		return false

# sets the position the NavAgent will move to
func setTargetPosition(target):
	target_node = null
	priority_movement = true
	destination = target

# sets the worker's target node
func setTarget(target):
	if target_node != null and str(target_node.getType()) == "resource":
		previous_target = target_node # stores the previous target if it was a resource
	target_node = target
	setDestination(target_node.global_position) # also sets target's position as new movement destination

# sets the worker's movement destination
func setDestination(new_destination):
	destination = new_destination

# returns the worker's current movement destination
func getDestination():
	return destination

# receives the path from NavAgent
func move_to(target_pos):
	path = navi.get_simple_path(global_transform.origin, target_pos)
	path_ind = 0

# returns the worker's current position
func getPosition():
	return global_position

# returns the worker's navigation agent
func getNavigationAgent():
	return navi

# returns the worker's current movement speed
func getMovementSpeed():
	return SPEED

# returns the worker's current proximity distance
func getProximity():
	return PROXIMITY_DISTANCE

# causes the worker to take a given amount of damage
func takeDamage(damage, _attacker):
	hp -= damage # subtracts the damage taken from the current hp
	$HealthBarSprite.visible = true
	$HealthbarContainer/HealthBar.value = hp # updates the health bar display
	if hp <= 0: # removes the worker if it's remaining hp is 0 or less
		deleted.emit(self) # tells the system to clear remaining references to the worker
		queue_free() # then deletes the worker

# sets attack target (has no effect for the worker)
func setAttackTarget(_unit):
	pass

# updates the worker's carried resource
func setResource(new_resource):
	resource = new_resource

# returns the worker's currently carried resource
func getResource():
	return resource

# returns the state of the worker's currently carried resource
func getResourceState():
	if resource == [0, 0]:
		return 0
	return 1

# returns the worker's current target node
func getActiveTarget():
	return target_node

# returns the worker's saved previous resource node target
func getPrevious():
	return previous_target

# returns a list of the resources the worker knows
func getKnownResources():
	return known_resources

# removes a cleared resource node from the worker's list if it is on there
func removeResourceKnowledge(removed_resource):
	if known_resources.has(removed_resource):
		known_resources.erase(removed_resource)

# returns the worker's HQ
func getHQ():
	return hq

# sets the worker's faction to a given value
func setFaction(f : int):
	faction = f
	$rebel_anim/Armature_002/Skeleton3D/WorkerBody.material_override = load(Global.getFactionColor(faction))
	
	if destination == null:
		destination = global_position # if the worker is first set up, also sets up the movement variable

# returns the worker's current faction
func getFaction():
	return faction

# returns the combat target type (worker)
func getType():
	return TARGET_TYPE

# returns the worker's physical size
func getSize():
	return $WorkerColl.shape.radius

# changes the color of the worker when selected
func select():
	pass
	$rebel_anim/Armature_002/Skeleton3D/WorkerBody.material_override = load(Global.getSelectedFactionColor(faction))

# changes the color of the worker when it is deselected
func deselect():
	pass
	$rebel_anim/Armature_002/Skeleton3D/WorkerBody.material_override = load(Global.getFactionColor(faction))

# if a new resource entered the worker's detection radius, adds it to its list
func _on_range_area_body_entered(body):
	if body.is_in_group("resource") and !known_resources.has(body):
		known_resources.append(body)

# advances the worker's interaction state once it has finished mining
func _on_mining_timer_timeout():
	advanceInteractionState()
