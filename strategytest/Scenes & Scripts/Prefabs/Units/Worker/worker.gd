extends CharacterBody3D

signal unit_menu(unit) # to open this worker's inspect menu
signal interface_update() # to update the worker's open inspect menu
signal deleted(worker) # to tell the system that the worker has been removed

const TARGET_PRIORITY = ["combat", "hq", "worker", "building", "forge"] # the worker's targeting priority based on types
const TARGET_TYPE = "worker" # the worker's combat type
const DISPLAY_NAME = "@name_unit_worker"
const MINE_SPEED = 5.0 # the speed at which the worker acquired resources
const INTERACTION_STATE_MAX = 2 # the maximum value of the worker's interaction state
const PROXIMITY_DISTANCE = 10.0 # the worker's proximity distance

var SR
var interaction_state = 0 # which state of its object interaction is the worker currently in?
var path = [] # the navigation path the worker is traveling on
var path_ind = 0 # the index of the worker's current path node
var resource = [0,0] # what type of resource is the worker carrying, and how much of it?
var nearby_enemies = [] # all enemy targets that are currently within range of the worker
var known_resources = [] # an array of all resource nodes the worker has discovered
var current_observers = []
var priority_movement = false # is the worker's currently overwritten by a player input?
var destination # the worker's current navigation destination
var target_node # the node the worker currently is targeting
var target_mode : int # which targeting mode is the worker currently following? (0 = resources, 1 = combat)
var previous_target # the worker's previously targeted resource

var hp : float # the worker's current hit points
var can_attack = true # can the worker currently attack (is its attack not on cooldown)?
var attacking = false # is the worker playing its attack animation?
var is_awake = true # is the worker currently actively acting?
var is_walking = false # checks if the worker is currently walking

var unit_type : String # the worker's type
var faction : int # which faction does this worker belong to?
var max_hp : float # the worker's maximum hit points
var damage_value : float # the damage the worker deals with each attack
var attack_range : float # the distance at which the worker can attack enemy targets
var attack_speed : float # the rate at which the worker attacks
var detection_range : float # the distance at which the worker can detect other units
var speed : float # the worker's movement speed

@onready var navi : NavigationAgent3D = $NavAgent # the navigation agent controlling the worker's movement
@onready var hq = $".." # the hq the worker belongs to
@onready var worker_anim = $OutlawWorker/AnimationPlayer #  animationplayer for the ol model
@onready var worker_anim_nl = $NewLightsWorker/AnimationPlayer #  animationplayer for the nl model

var selected = false



# controls the worker's behaviour
func _physics_process(delta):
	Global.healthbar_rotation($HealthBarSprite)
	if is_awake:
		await $UnitBehaviours.runBehaviours(self, delta) # calls the worker's behaviour tree
		worker_rotation() # permanently sets the direction the worker is facing
		animationControl() # then plays the correct animation based on the worker's current state
		
		interface_update.emit() # updates the worker's inspect menu


# rotates the model to face in the right direction
func worker_rotation():
	var nav = $NavAgent.get_next_path_position() # position where the worker moves next on his path to the final destination
	# Ashfolk worker rotation
	$OutlawWorker/OutlawWorker.look_at(nav) # looks at the next position
	$OutlawWorker/OutlawWorker.rotation.x = rad_to_deg(90) # locks the rotation of x
	$OutlawWorker/OutlawWorker.rotate_object_local(Vector3.UP, PI) # flips the model 
	# New Lights worker rotation
	$NewLightsWorker/Armature.look_at(nav) # looks at the next position
	$NewLightsWorker/Armature.rotation.x = rad_to_deg(90) # locks the rotation of x
	$NewLightsWorker/Armature.rotate_object_local(Vector3.UP, PI) # flips the model 


# controls the worker's animation
func animationControl():
	if !attacking:
		if interaction_state == 1:
			worker_anim.play("OutlawWorkerHarvest") # plays the attack animation if the worker is mining
			worker_anim_nl.play("LightSoldierHarvest") # plays the harvest animation if the worker is mining
			$NewLightsWorker/Armature/Skeleton3D/BoneAttachment3D/NL_Pickaxe.visible = true # swaps the gun to pickaxe
			$NewLightsWorker/Armature/Skeleton3D/BoneAttachment3D/NL_rifle.visible = false # swaps the gun to pickaxe
			
		elif velocity != Vector3.ZERO: # when worker is moving
			worker_anim.play("OutlawWorkerJog") # plays the walk animation if they are moving
			worker_anim_nl.play("LightSoldierRun") # plays the walk animation if they are moving
			if is_walking == false and $".".visible == true: #  # sets the walking sound for the ashfolk worker
				is_walking = true # sets the var to is walking
				if faction == 0: # sets the correct sound 
					$WalkStreamer.stream = load("res://Sounds/Walk_Ashfolk.mp3")
				elif faction == 1:
					$WalkStreamer.stream = load("res://Sounds/Walk_Ashfolk.mp3")
				$WalkStreamer.play()
		else: #stops the walk sound when worker is standing still
			is_walking = false
			$WalkStreamer.stop()
			worker_anim.play("OutlawWorkerIdle") # plays the idle animation otherwise
			worker_anim_nl.play("LightSoldierIdle") # plays the idle animation otherwise
	
	if worker_anim.current_animation == "OutlawWorkerJog": # when the worker is playing the walk animation the particles are emitted
		$OutlawWorker/OutlawWorker/Skeleton3D/BoneAttachment3D2/GPUParticles3D.emitting = true # starts particles
	else: #  when walking stops the particles stop spawning
		$OutlawWorker/OutlawWorker/Skeleton3D/BoneAttachment3D2/GPUParticles3D.emitting = false # stops particles
	if worker_anim_nl.current_animation == "LightSoldierRun": # when the worker is playing the walk animation the particles are emitted
		$NewLightsWorker/Armature/Skeleton3D/BoneAttachment3D2/GPUParticles3D.emitting = true # starts particles
	else: #  when walking stops the particles stop spawning
		$NewLightsWorker/Armature/Skeleton3D/BoneAttachment3D2/GPUParticles3D.emitting = false # stops particles

# sets up the worker and its properties when it is spawned
func setUp(type):

	# sets the various properties from the given values for the worker's type
	unit_type = type
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
	$RangeArea/RangeColl.shape.set_radius(detection_range)
	
	await get_tree().physics_frame
	destination = global_position # sets the initial navigation target to the unit's own position

# calls the worker to start mining
func startMiningState():
	$MiningTimer.start(MINE_SPEED)
	await get_tree().create_timer(1).timeout
	if Global.player_faction == faction:
		Sound.play_sound("res://Sounds/MiningSound_Rebells_FreeSoundCommunity.mp3",$"." )

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

# returns whether or not the worker is currently acting on priority movement
func getPriorityMovement():
	return priority_movement

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
	previous_target = null
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
	Sound.under_Attack()
	interface_update.emit()
	if hp <= 0: # calls the worker's death function if its remaining hp is 0 or less
		startDeathState()
	elif target_node == null or target_node.getType() != "combat" and !priority_movement:
		target_node = attacker # causes the worker to fight back if it does not yet have a target
		setTargetMode(1)

# returns the worker's current HP
func getHP():
	return hp

# returns the worker's maximum HP
func getMaxHP():
	return max_hp

# returns the worker's display name id
func getDisplayName():
	return DISPLAY_NAME

# calls to open the worker's inspect menu
func accessUnit():
	unit_menu.emit(self)

# returns information about the worker's current state
func getInspectInfo(info):
	match info:
		# returns information on the worker's current activity status
		"status":
			if interaction_state == 1:
				return "working" # returns "working" if the worker is currently acquiring resources
			elif target_mode == 1:
				return "fighting" # returns "fighting" if the worker is currently in combat mode
			elif velocity != Vector3.ZERO:
				return "moving" # returns "moving" if the worker is in motion
			else:
				return "inactive" # returns "inactive" otherwise
		
		# returns information on the resource (if any) the worker is currently carrying
		"resource":
			if resource == [0,0]:
				return "empty"
			match resource[0]:
				0:
					match faction:
						0:
							return "scrap"
						1:
							return "zenecium"
				1:
					return "ferronite"

# starts the worker's death state
func startDeathState():
	is_awake = false 
	deleted.emit(self) # tells the system to clear remaining references to the worker
	for group in get_groups():
		remove_from_group(group) # removes the worker from all groups
	
	$HealthBarSprite.visible = false
	worker_anim.play("OutlawWorkerDeath") # starts the death animation
	worker_anim_nl.play("LightSoldierDeath")

# sets attack target (has no effect for the worker)
func setAttackTarget(target):
	if target.is_in_group("CombatTarget") and target.getFaction() != faction:
		clearAttackTarget()
		priority_movement = true
		target_node = target # sets the target if the given entity is a valid target and belongs to an enemy faction
		setTargetMode(1)

# attack the worker's current target
func startAttackCooldown():
	can_attack = false # disables the worker's attack
	$AttackTimer.start(attack_speed) # starts the attack cooldown
	worker_anim.play("OutlawWorkerAttack") # plays the attack animation if the worker is mining
	worker_anim_nl.play("LightSoldierAttack")# plays the attack animation 
	if $NewLightsWorker.visible == true:
		Sound.play_sound("res://Sounds/GunShot_Ashfolk.mp3",$"." )

	attacking = true

# sets the target's position as the movement destination
func focusAtTarget():
	if target_node != null:
		destination = target_node.global_position

# returns a list of enemy units currently near the unit
func getNearbyEnemies():
	return nearby_enemies

# causes the worker to exit combat mode
func leaveCombatMode():
	if target_mode == 1:
		target_mode = 0

# returns the unit's targeting priority
func getTargetPriority():
	return TARGET_PRIORITY

# returns the unit's attack damage value
func getAttackDamage():
	return damage_value

# returns the unit's current attack range
func getAttackRange():
	if getActiveTarget().getType() == "hq":
		return attack_range * 2
	return attack_range

# returns if the unit's attack is currently available
func getAttackAvailability():
	return can_attack

# updates the worker's carried resource
func setResource(new_resource):
	resource = new_resource

func clearResource():
	resource = [0,0]
	if target_node == hq:
		target_node = null
		destination = global_position

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

# called when another unit dies
func checkUnitRemoval(unit):
	if target_node == unit:
		clearAttackTarget() # clears attack target if the other unit was the worker's target
	if current_observers.has(unit):
		fowExit(unit) # removes the unit from the worker's observers

# clears the worker's attack target
func clearAttackTarget():
	target_node = null
	target_mode = 0

# sets the worker's targeting mode
func setTargetMode(mode):
	target_mode = mode

# returns the worker's current targeting mode
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
	# if the worker was targeting the resource, also resets the workers target & destination
	if target_node == removed_resource:
		target_node = null
		destination = global_position

func clearKnowledge():
	target_node = null
	previous_target = null
	destination = global_position
	known_resources.clear()

# returns the worker's HQ
func getHQ():
	return hq

# sets the worker's faction to a given value
func setFaction(f : int):
	faction = f
	if destination == null:
		destination = global_position # if the worker is first set up, also sets up the movement variable
	if faction == 0:
		$OutlawWorker.visible = true
	elif faction == 1:
		$NewLightsWorker.visible = true

# returns the worker's current faction
func getFaction():
	return faction

# returns the combat target type (worker)
func getType():
	return TARGET_TYPE

# returns the worker's unit type id
func getUnitType():
	return unit_type

# returns the worker's physical size
func getSize():
	return $WorkerColl.shape.radius

# changes the color of the worker when selected
func select():
	selected = true

# changes the color of the worker when it is deselected
func deselect():
	pass

# checks if there are any AI-controlled targets near the node
func hasNearbyAI():
	var nearby_objects = $RangeArea.get_overlapping_bodies()
	for object in nearby_objects:
		if object.has_method("getFaction") and !object.has_method("takeResource") and object.getFaction() != faction:
			return true # returns true on the first enemy object found
	return false # returns false instead if none are found

# called when the worker comes into view of a player-controlled unit
func fowEnter(node):
	fowReveal(true) # makes the worker visible
	if node.getFaction() != faction:
		current_observers.append(node) # adds the player unit to the worker's observers
		fowReveal(true) # makes the worker visible

# called when the worker is no longer in view of a player-controlled unit
func fowExit(node):
	if current_observers.has(node):
		current_observers.erase(node) # removes the player unit from the worker's observers
		if current_observers.size() == 0:
			fowReveal(false) # if no observers remain, makes the worker invisible

# sets the worker's visibility to a given state
func fowReveal(bol):
	if visible != bol:
		visible = bol

# if a new resource entered the worker's detection radius, adds it to its list
func _on_range_area_body_entered(body):
	if body.is_in_group("FowObject") and faction == Global.player_faction:
		body.fowEnter(self) # triggers the objects fow detection
	if body.is_in_group("resource") and !known_resources.has(body) and body.getFaction(faction) == faction:
		known_resources.append(body) # adds the object to the list of known resources if it is a resource that the worker's faction can utilize
	elif body.is_in_group("CombatTarget") and body.getFaction() != faction:
		nearby_enemies.append(body) # adds the object to the list of nearby enemies if it is a valid target and belongs to an enemy faction
		if priority_movement:
			priority_movement = false
			setAttackTarget(body)
		if faction != Global.player_faction:
			Global.addKnownTarget(body) # adds the body to the AI's list of known targets

# when an object leaves the worker's detection range
func _on_range_area_body_exited(body):
	if body.is_in_group("FowObject") and faction == Global.player_faction:
		body.fowExit(self) # updates the object's fow detection
	if nearby_enemies.has(body):
		nearby_enemies.erase(body) # removes the object from the list of nearby enemies if it was in the list
		if faction != Global.player_faction and (body.getType() == "worker" or body.getType() == "combat"):
			Global.removeKnownTarget(body) # attempts to remove the body from the AI's list of known targets

# advances the worker's interaction state once it has finished mining
func _on_mining_timer_timeout():
	advanceInteractionState()

# re-enables attack when the attack cooldown ends
func _on_attack_timer_timeout():
	can_attack = true

# calls functions when specific animations finish playing
func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"OutlawWorkerAttack":
			attacking = false # lets the worker play other animations again once their attack animation has run
		"OutlawWorkerDeath":
			queue_free() # deletes the worker once their death animation has finished
		"LightSoldierAttack":
			attacking = false # lets the worker play other animations again once their attack animation has run
		"LightSoldierDeath":
			queue_free() # deletes the worker once their death animation has finished
			
func getIcon():
	if Global.player_faction == 0:
		return load("res://Assets/UI/OL_Worker_UI.png")
	else:
		return load("res://Assets/UI/NL_lightsoldier_UI.png")
