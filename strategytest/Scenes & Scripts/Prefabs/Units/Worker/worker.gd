extends CharacterBody3D

signal deleted(worker) # to tell the system that the worker has been removed

const TARGET_PRIORITY = ["combat", "hq", "building", "worker"] # the worker's targeting priority based on types
const TARGET_TYPE = "worker" # the worker's combat type
const MINE_SPEED = 5.0 # the speed at which the worker acquired resources
const INTERACTION_STATE_MAX = 2 # the maximum value of the worker's interaction state
const PROXIMITY_DISTANCE = 5.0 # the worker's proximity distance

var SR
var interaction_state = 0 # which state of its object interaction is the worker currently in?
var path = [] # the navigation path the worker is traveling on
var path_ind = 0 # the index of the worker's current path node
var resource = [0, 0] # what type of resource is the worker carrying, and how much of it?
var nearby_enemies = [] # all enemy targets that are currently within range of the worker
var known_resources = [] # an array of all resource nodes the worker has discovered
var priority_movement = false # is the worker's currently overwritten by a player input?
var destination # the worker's current navigation destination
var target_node # the node the worker currently is targeting
var target_mode : int # which targeting mode is the worker currently following? (0 = resources, 1 = combat)
var previous_target # the worker's previously targeted resource

var hp : float # the worker's current hit points
var can_attack = true # can the worker currently attack (is its attack not on cooldown)?

var unit_type : int # the worker's type
var faction : int # which faction does this worker belong to?
var max_hp : float # the worker's maximum hit points
var damage_value : float # the damage the worker deals with each attack
var attack_range : float # the distance at which the worker can attack enemy targets
var attack_speed : float # the rate at which the worker attacks
var detection_range : float # the distance at which the worker can detect other units
var speed : float # the worker's movement speed

@onready var navi : NavigationAgent3D = $NavAgent # the navigation agent controlling the worker's movement
@onready var hq = $".." # the hq the worker belongs to
@onready var worker_anim = $OutlawWorkerAllAnimationsBaked/AnimationPlayer #  animationplayer for the model

# controls the worker's behaviour
func _physics_process(delta):
	worker_rotation() # permanently sets the direction the worker is facing
	if worker_anim.current_animation == "OutlawWorkerJog": # when the worker is playing the walk animation the particles are emitted
		$OutlawWorkerAllAnimationsBaked/OutlawWorker/Skeleton3D/BoneAttachment3D2/GPUParticles3D.emitting = true # starts particles
	else: #  when walking stops the particles stop spawning
		$OutlawWorkerAllAnimationsBaked/OutlawWorker/Skeleton3D/BoneAttachment3D2/GPUParticles3D.emitting = false # stops particles
	await $UnitBehaviours.runBehaviours(self, delta) # calls the worker's behaviour tree
	animationControl() # then plays the correct animation based on the worker's current state

# rotates the model to face in the right direction
func worker_rotation():
	var nav = $NavAgent.get_next_path_position() # position where the worker moves next on his path to the final destination
	$OutlawWorkerAllAnimationsBaked/OutlawWorker.look_at(nav) # looks at the next position
	$OutlawWorkerAllAnimationsBaked/OutlawWorker.rotation.x = rad_to_deg(90) # locks the rotation of x
	$OutlawWorkerAllAnimationsBaked/OutlawWorker.rotate_object_local(Vector3.UP, PI) # flips the model 

# controls the worker's animation
func animationControl():
	if interaction_state == 1:
		worker_anim.play("OutlawWorkerHarvest") # plays the attack animation if the worker is mining
	elif velocity != Vector3.ZERO:
		worker_anim.play("OutlawWorkerJog") # plays the walk animation if they are moving
	else:
		worker_anim.play("OutlawWorkerIdle") # plays the idle animation otherwise

# sets up the worker and its properties when it is spawned
func setUp(type):
	# sets the various properties from the given values for the worker's type
	max_hp = Global.unit_dict[str(type)]["max_hp"]
	damage_value = Global.unit_dict[str(type)]["damage_value"]
	attack_range = Global.unit_dict[str(type)]["attack_range"]
	attack_speed = Global.unit_dict[str(type)]["attack_speed"]
	detection_range = Global.unit_dict[str(type)]["detection_range"]
	speed = Global.unit_dict[str(type)]["speed"]
	
	hp = max_hp # sets initial hp to max hp
	
	$HealthbarContainer/HealthBar.max_value = max_hp # adjusts the health bar display to this unit's maximum hp
	$HealthbarContainer/HealthBar.value = hp
	$RangeArea/RangeColl.shape = $RangeArea/RangeColl.shape.duplicate()
	$RangeArea/RangeColl.shape.radius = detection_range
	
	await get_tree().physics_frame
	destination = global_position # sets the initial navigation target to the unit's own position

# calls the worker to start mining
func startMiningState():
	$MiningTimer.start(MINE_SPEED)
	await get_tree().create_timer(1).timeout
	if Global.player_faction == faction:
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
func isActive():
	if target_node != null or known_resources.size() > 0 or resource != [0, 0] or priority_movement:
		return true # returns true if the worker is delivering a crystal or knows of any remaining resource nodes
	else:
		return false

# checks if the unit is near a given body
func isNearBody(node):
	if $RangeArea.overlaps_body(node):
		return true
	else:
		return false

# sets the position the NavAgent will move to
func setTargetPosition(target):
	if nearby_enemies.size() != 0 or target_node != null:
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
	return speed

# returns the worker's current proximity distance
func getProximity():
	return PROXIMITY_DISTANCE

# causes the worker to take a given amount of damage
func takeDamage(damage, attacker):
	hp -= damage # subtracts the damage taken from the current hp
	$HealthBarSprite.visible = true
	$HealthbarContainer/HealthBar.value = hp # updates the health bar display
	if hp <= 0: # removes the worker if it's remaining hp is 0 or less
		deleted.emit(self) # tells the system to clear remaining references to the worker
		queue_free() # then deletes the worker
	elif target_node == null or target_node.getType() != "combat":
		priority_movement = false
		target_node = attacker # causes the worker to fight back if it does not yet have a target
		setTargetMode(1)

# sets attack target (has no effect for the worker)
func setAttackTarget(target):
	if target.is_in_group("CombatTarget") and target.getFaction() != faction:
		target_node = target # sets the target if the given entity is a valid target and belongs to an enemy faction
		setTargetMode(1)

# attack the worker's current target
func startAttackCooldown():
	can_attack = false # disables the worker's attack
	$AttackTimer.start(attack_speed) # starts the attack cooldown

# sets the target's position as the movement destination
func focusAtTarget():
	if target_node != null:
		destination = target_node.global_position

# returns a list of enemy units currently near the unit
func getNearbyEnemies():
	return nearby_enemies

# returns the unit's targeting priority
func getTargetPriority():
	return TARGET_PRIORITY

# returns the unit's attack damage value
func getAttackDamage():
	return damage_value

# returns the unit's current attack range
func getAttackRange():
	return attack_range

# returns if the unit's attack is currently available
func getAttackAvailability():
	return can_attack

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

func setTargetMode(mode):
	target_mode = mode

func getTargetMode():
	return target_mode

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
	#$rebel_anim/Armature_002/Skeleton3D/WorkerBody.material_override = load(Global.getSelectedFactionColor(faction))

# changes the color of the worker when it is deselected
func deselect():
	pass
	#$rebel_anim/Armature_002/Skeleton3D/WorkerBody.material_override = load(Global.getFactionColor(faction))

# if a new resource entered the worker's detection radius, adds it to its list
func _on_range_area_body_entered(body):
	if body.is_in_group("resource") and !known_resources.has(body):
		known_resources.append(body)
	elif body.is_in_group("CombatTarget") and body.getFaction() != faction:
		nearby_enemies.append(body) # adds the object to the list of nearby enemies if it is a valid target and belongs to an enemy faction
		if priority_movement:
			priority_movement = false
			setAttackTarget(body)

# when an object leaves the worker's detection range
func _on_range_area_body_exited(body):
	if nearby_enemies.has(body):
		nearby_enemies.erase(body) # removes the object from the list of nearby enemies if it was in the list

# advances the worker's interaction state once it has finished mining
func _on_mining_timer_timeout():
	advanceInteractionState()

# re-enables attack when the attack cooldown ends
func _on_attack_timer_timeout():
	can_attack = true
