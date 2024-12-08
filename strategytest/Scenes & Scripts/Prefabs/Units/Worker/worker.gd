extends CharacterBody3D

signal deleted(worker) # to tell the system that the worker has been removed

const TARGET_TYPE = "worker" # the worker's combat type
const SPEED = 10.0 # the worker's movement speed
const MAX_HP = 2.0 # the worker's maximum hit points
const MINE_SPEED = 5.0
const INTERACTION_STATE_MAX = 2
const PROXIMITY_DISTANCE = 5.0

var SR
var faction = 0 # which faction does the worker belong to?
var interaction_state = 0 # which state of its object interaction is the worker currently in?
var path = [] # the navigation path the worker is traveling on
var path_ind = 0 # the index of the worker's current path node
var resource = [0, 0] # what type of resource is the worker carrying, and how much of it?
var known_resources = [] # an array of all resource nodes the worker has discovered
var priority_movement = false # is the worker's currently overwritten by a player input?
var has_moved = false
var destination # the worker's current navigation destination
var target_node
var previous_target

@onready var hp = MAX_HP # the worker's current hit points, set to the maximum on instantiation
@onready var navi : NavigationAgent3D = $NavAgent # the navigation agent controlling the worker's movement
@onready var hq = $".." # the hq the worker belongs to

# called when the worker is first instantiated
func _ready():
	$HealthbarContainer/HealthBar.max_value = MAX_HP # adjusts the health bar display to this unit's maximum hp
	$HealthbarContainer/HealthBar.value = hp
	await get_tree().physics_frame
	velocity = Vector3.ZERO

# controls the worker's movement and other actions
func _physics_process(delta):
	await $UnitBehaviours.runBehaviours(self, delta)
	animationControl()

func startMiningState():
	$MiningTimer.start(MINE_SPEED)
	await get_tree().create_timer(1).timeout
	Sound.play_sound("res://Sounds/MiningSound_Rebells_FreeSoundCommunity.mp3")

func getPosition():
	return global_position

func getDestination():
	return destination

func getResourceState():
	if resource == [0, 0]:
		return 0
	return 1

func getNavigationAgent():
	return navi

func getMovementSpeed():
	return SPEED

func getProximity():
	return PROXIMITY_DISTANCE

func getActiveTarget():
	return target_node

func getInteractionState():
	return interaction_state

func getPrevious():
	return previous_target

func getKnownResources():
	return known_resources

func getHQ():
	return hq

func getResource():
	return resource

func setResource(new_resource):
	resource = new_resource

func advanceInteractionState():
	if interaction_state < INTERACTION_STATE_MAX:
		interaction_state += 1
	else:
		interaction_state = 0

func setTarget(target):
	if target_node != null and str(target_node.getType()) == "resource":
		previous_target = target_node
	target_node = target
	setDestination(target_node.global_position)

func setDestination(new_destination):
	destination = new_destination
	if !has_moved:
		has_moved = true

func animationControl():
	if interaction_state == 1:
		$rebel_anim/AnimationPlayer.play("attack")
	elif velocity != Vector3.ZERO:
		$rebel_anim/AnimationPlayer.play("walk")
	else:
		$rebel_anim/AnimationPlayer.play("idle")

# receives the path from NavAgent
func move_to(target_pos):
	path = navi.get_simple_path(global_transform.origin, target_pos)
	path_ind = 0
	
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

# checks if the worker is currently doing anything
func isWorking():
	if known_resources.size() > 0 or resource != [0, 0] or priority_movement:
		return true # returns true if the worker is delivering a crystal or knows of any remaining resource nodes
	else:
		return false

# changes the color of the worker when selected
func select():
	pass
	$rebel_anim/Armature_002/Skeleton3D/WorkerBody.material_override = load(Global.getSelectedFactionColor(faction))

# changes the color of the worker when it is deselected
func deselect():
	pass
	$rebel_anim/Armature_002/Skeleton3D/WorkerBody.material_override = load(Global.getFactionColor(faction))

# sets the position the NavAgent will move to
func setTargetPosition(target):
	target_node = null
	priority_movement = true
	destination = target

# removes a cleared resource node from the worker's list if it is on there
func removeResourceKnowledge(removed_resource):
	if known_resources.has(removed_resource):
		known_resources.erase(removed_resource)

# if a new resource entered the worker's detection radius, adds it to its list
func _on_range_area_body_entered(body):
	if body.is_in_group("resource") and !known_resources.has(body):
		known_resources.append(body)

func _on_mining_timer_timeout():
	advanceInteractionState()
