extends CharacterBody3D

signal unit_menu(unit) # to open this unit's inspect menu
signal interface_update() # to update this unit's active inspect menu
signal deleted(unit) # to tell the system the unit has been defeated

const TARGET_TYPE = "combat" # the unit's target type
const TARGET_PRIORITY = ["combat", "worker", "hq", "building", "forge"] # the unit's targeting priority based on types

var can_attack = true # can the unit currently attack (is its attack not on cooldown)?
var nearby_enemies = [] # all enemy targets that are currently within range of the unit
var active_target : PhysicsBody3D # the enemy target the unit is currently attacking
var priority_movement = false # is the unit's movement overridden by a player command
var current_observers = [] # the enemy units currently observing this unit
var is_walking = false

var attacking = false # is the unit currently attacking?
var path = [] # the path the unit is navigating on
var path_ind = 0 # the id of the unit's current path position
var destination : Vector3 # the unit's current navigation target
var SR 
var is_awake = true # is the unit awake (i.e. not dying)?

var display_name : String # the unit's display name id, based on its type
var unit_type : int # the unit's type
var faction : int # which faction does this unit belong to?
var max_hp : float # the units maximum hit points
var damage_value : float # the damage the unit deals with each attack
var attack_range : float # the distance at which the unit can attack enemy targets
var attack_speed : float # the rate at which the unit attacks
var detection_range : float # the distance at which the unit can detect other units
var speed : float # the unit's movement speed
var upgrade_received = false # has the unit received an upgrade?

@onready var hp = max_hp # the unit's current hp, starting as its maximum hp
@onready var navi : NavigationAgent3D = $NavAgent # the navigation agent controlling the unit's movement
@onready var unit_anim = $UnitBody/AnimationPlayer
# controls the unit's movement and other actions
func _physics_process(delta):
	#if Input.is_action_just_pressed("shift"):
		#print()
	Global.healthbar_rotation($HealthBarSprite)
	if is_awake:
		$UnitBehaviours.runBehaviours(self, delta)
		unit_rotation()
		animationControl()
		interface_update.emit() # updates the unit's interface, if active
	

# receives the path from NavAgent
func move_to(target_pos):
	path = navi.get_simple_path(global_transform.origin, target_pos)
	path_ind = 0

# causes the unit to take a given amount of damage
func takeDamage(damage, attacker):
	hp -= damage # subtracts the damage taken from the current hp
	$HealthBarSprite.visible = true
	$HealthbarContainer/HealthBar.value = hp # updates the health bar display
	Sound.under_Attack()
	interface_update.emit()
	if hp <= 0: # removes the unit if it's remaining hp is 0 or less
		startDeathState()
	elif active_target == null or TARGET_PRIORITY.find(active_target.getType()) > TARGET_PRIORITY.find(attacker.getType()):
		priority_movement = false
		active_target = attacker # causes the unit to fight back if it does not yet have a target


func startDeathState():
	is_awake = false
	deleted.emit(self) # tells the system to clear remaining references to the worker
	for group in get_groups():
		remove_from_group(group) # removes the worker from all groups
	$HealthBarSprite.visible = false
	$UnitBody/AnimationPlayer.play("OutlawFighterDeath") # starts the death animation
	$NL_Heavy/HeavyAnim.play("HeavyDefenseUnitDeath")

# calls to access the inspect menu for this unit
func accessUnit():
	unit_menu.emit(self)

# returns the unit's current HP
func getHP():
	return hp

# returns the unit's maximum HP
func getMaxHP():
	return max_hp

# returns the unit's display name id
func getDisplayName():
	return display_name 

# return information about the unit's state
func getInspectInfo(info):
	match info:
		# returns the unit's current activity status
		"status":
			if active_target != null:
				return "fighting" # returns "fighting" if the unit has an active combat target
			elif velocity != Vector3.ZERO:
				return "moving" # returns "moving" if the unit is in motion
			else:
				return "inactive" # returns "inactive" otherwise

# attack the unit's current target
func startAttackCooldown():
	can_attack = false # disables the unit's attack
	attacking = true
	$AttackCooldown.start(attack_speed) # starts the attack cooldown
	unit_anim.play("OutlawFighterRifleFire")
	$NL_Heavy/HeavyAnim.play("HeavyDefenseUnitAttack")
	match unit_type:
		1:
			Sound.play_sound("res://Sounds/GunShot_NewLights.mp3",$"." )
		2:
			Sound.play_sound("res://Sounds/GunShot_Ashfolk.mp3",$"." )
		3:
			Sound.play_sound("res://Sounds/GunShot_Ashfolk.mp3",$"." )
			$OutlawGunVehicleBaked/OL_GunVehicleWheels2/Gunfire.shoot()
			$OutlawGunVehicleBaked/OL_GunVehicleWheels2/Gunfire2.shoot()
	$AttackAnim/AnimationPlayer.play("attack")
	attacking = true
	await $NL_Heavy/HeavyAnim.animation_finished
	
	
# sets the target's position as the movement destination
func focusAtTarget():
	if active_target != null:
		destination = active_target.global_position

# sets up the unit and its properties when it is spawned
func setUp(type):
	# sets the various properties from the given values for the unit's type
	unit_type = type
	display_name = Global.unit_dict[str(type)]["name"]
	max_hp = Global.unit_dict[str(type)]["max_hp"]
	damage_value = Global.unit_dict[str(type)]["damage_value"]
	attack_range = Global.unit_dict[str(type)]["attack_range"]
	attack_speed = Global.unit_dict[str(type)]["attack_speed"]
	detection_range = Global.unit_dict[str(type)]["detection_range"]
	speed = Global.unit_dict[str(type)]["speed"]
	
	hp = max_hp # sets initial hp to max hp
	
	# placeholder display for differentiating different unit types
	match type:
		0:
			$TypeIdentifier.set_surface_override_material(0, load("res://Assets/Materials/material_yellow.tres"))
		1:
			$TypeIdentifier.set_surface_override_material(0, load("res://Assets/Materials/material_green.tres"))
			$NL_Heavy.visible = true
			$UnitBody.visible = false
			$HealthBarSprite.position.y = 3
		2:
			$TypeIdentifier.set_surface_override_material(0, load("res://Assets/Materials/material_purple.tres"))
		3:
			$TypeIdentifier.set_surface_override_material(0, load("res://Assets/Materials/material_orange.tres"))
			$OutlawGunVehicleBaked.visible = true
			$UnitBody.visible = false


	$HealthbarContainer/HealthBar.max_value = max_hp # adjusts the health bar display to this unit's maximum hp
	$HealthbarContainer/HealthBar.value = hp
	$RangeArea/RangeColl.shape = $RangeArea/RangeColl.shape.duplicate()
	$RangeArea/RangeColl.shape.radius = detection_range
	#$AttackAnim.mesh = $AttackAnim.mesh.duplicate()
	
	await get_tree().physics_frame
	destination = global_position # sets the initial navigation target to the unit's own position

# returns the unit's upgrade state
func getUpgradeState():
	return upgrade_received

func update_stats(): # function to upgrade units
	if Balance.upgrade1[faction] == true and !upgrade_received: # if global var is active, and the unit hasn't been upgraded yet
		setUp(0) # runs the setUp function again
		max_hp = Balance.u_ranged_hp # switches the stats to upgraded ones
		damage_value = Balance.u_ranged_damage # switches the stats to upgraded ones
		hp = max_hp # switches the stats to upgraded ones
		$HealthbarContainer/HealthBar.max_value = max_hp # adjusts the health bar display to this unit's maximum hp
		$HealthbarContainer/HealthBar.value = hp # resets value
		upgrade_received = true # sets the upgrade as received

# sets the unit's faction to a given value
func setFaction(f : int):
	update_stats() # when spawned check for upgrade and sets stats accordingly
	faction = f

# changes the color of the unit when selected
func select():
	return
	$UnitBody/Armature/Skeleton3D/FighterBake.set_surface_override_material(1, load(Global.getSelectedFactionColor(faction)))

# changes the color of the unit when it is deselected
func deselect():
	return
	$UnitBody/Armature/Skeleton3D/FighterBake.set_surface_override_material(1, load(Global.getFactionColor(faction)) )

# sets the unit's movement destination
func setDestination(new_destination):
	destination = new_destination
	if priority_movement:
		priority_movement = false
		

# overwrites the unit's actions with a specific movement destination
func setTargetPosition(target):
	if nearby_enemies.size() != 0 or active_target != null:
		active_target = null
		priority_movement = true
	destination = target

# returns the unit's current movement destination
func getDestination():
	return destination

# returns the unit's current position
func getPosition():
	return global_position

# attempts to set a given target as the unit's target
func setAttackTarget(target):
	if target.is_in_group("CombatTarget") and target.getFaction() != faction:
		active_target = target # sets the target if the given entity is a valid target and belongs to an enemy faction

# clears references to a defeated unit from this unit
func checkUnitRemoval(unit):
	if active_target == unit:
		clearAttackTarget()
	if current_observers.has(unit):
		fowExit(unit)

# clears the unit's attack target
func clearAttackTarget():
	active_target = null

# returns the unit's current active target
func getActiveTarget():
	return active_target

# sets the unit's targeting mode (always combat targeting)
func setTargetMode(_mode):
	pass

# returns the unit's current targeting mode (always combat targeting)
func getTargetMode():
	return 1

# returns a list of enemy units currently near the unit
func getNearbyEnemies():
	return nearby_enemies

# checks if the unit is active
func isActive():
	if active_target != null:
		return true # returns true if the unit has a target
	else:
		return false

# returns whether or not the unit is currently acting on priority movement
func getPriorityMovement():
	return priority_movement

# returns the unit's targeting priority
func getTargetPriority():
	return TARGET_PRIORITY

# returns the unit's attack damage value
func getAttackDamage():
	return damage_value

# returns the unit's current faction
func getFaction():
	return faction

# returns the unit's specific type
func getUnitType():
	return unit_type

# returns the unit's target type (combat)
func getType():
	return TARGET_TYPE

# returns the unit's physical size
func getSize():
	return $UnitColl.shape.radius

# return's the unit's navigation agent node
func getNavigationAgent():
	return navi

# returns the unit's current movement speed
func getMovementSpeed():
	return speed

# returns the unit's current attack range
func getAttackRange():
	return attack_range

# returns if the unit's attack is currently available
func getAttackAvailability():
	return can_attack

# checks if the unit is near a given body
func isNearBody(node):
	if $RangeArea.overlaps_body(node):
		return true
	else:
		return false

# checks if there are any AI-controlled targets near the node
func hasNearbyAI():
	var nearby_objects = $RangeArea.get_overlapping_bodies()
	for object in nearby_objects:
		if object.has_method("getFaction") and object.getFaction() != faction:
			return true # returns true on the first enemy object found
	return false # returns false instead if none are found

# called when the unit comes into view of a player-controlled unit
func fowEnter(node):
	if node.getFaction() != faction:
		current_observers.append(node) # adds the player unit to this unit's observers
		fowReveal(true) # makes the unit visible

# called when the unit is no longer in view of a player-controlled unit
func fowExit(node):
	if current_observers.has(node):
		current_observers.erase(node) # removes the player unit from this unit's observers
		if current_observers.size() == 0:
			fowReveal(false) # if no observers remain,n makes the unit invisible

# sets the unit's visibility to a given state
func fowReveal(bol):
	if visible != bol:
		visible = bol

# when a new object enters the unit's detection range
func _on_area_3d_body_entered(body):
	if body.is_in_group("FowObject") and faction == Global.player_faction:
		body.fowEnter(self) # triggers the object's fow detection
	if body.is_in_group("CombatTarget") and body.getFaction() != faction:
		nearby_enemies.append(body) # adds the object to the list of nearby enemies if it is a valid t arget and belongs to an enemy faction
		if priority_movement:
			priority_movement = false
			setAttackTarget(body)
		if faction != Global.player_faction:
			Global.addKnownTarget(body) # adds the body to the AI's list of known targets

# rotates the model to face in the right direction
func unit_rotation():
	var nav = $NavAgent.get_next_path_position() # position where the worker moves next on his path to the final destination
	$UnitBody.look_at(nav) # looks at the next position
	$UnitBody.rotation.x = rad_to_deg(0) # locks the rotation of x
	$UnitBody.rotate_object_local(Vector3.UP, PI) # flips the model 
	$OutlawGunVehicleBaked.look_at(nav) # looks at the next position
	$OutlawGunVehicleBaked.rotation.x = rad_to_deg(0) # locks the rotation of x
	$OutlawGunVehicleBaked.rotate_object_local(Vector3.UP, PI) # flips the model 
	$NL_Heavy.look_at(nav) # looks at the next position
	$NL_Heavy.rotation.x = rad_to_deg(0) # locks the rotation of x
	$NL_Heavy.rotate_object_local(Vector3.UP, PI) # flips the model
 
# plays the correct animation based on the unit's state
func animationControl():
	if !attacking:
		if velocity != Vector3.ZERO:
			unit_anim.play("OutlawFighterRun") # plays the walk animation if they are moving
			$NL_Heavy/HeavyAnim.play("HeavyDefenseUnitWalk")
			if is_walking == false and $".".visible == true: # checks when the unit is moving and visible on the map
				is_walking = true
				if faction == 1: # sets the walk sound based on faction and type
					match unit_type:
						0:
							$WalkStreamer.stream = load("res://Sounds/Walk_NewLights_Light.mp3")
							
						1:
							$WalkStreamer.stream = load("res://Sounds/Walk_NewLights_Heavy.mp3")
				elif faction == 0: # sets the walk sound based on faction and type
					match unit_type:
						0:
							$WalkStreamer.stream = load("res://Sounds/Walk_Ashfolk.mp3")
						3:
							$WalkStreamer.stream = load("res://Sounds/CarSound_NewLights.mp3")
				$WalkStreamer.play() # startet den streamer
		else:
			is_walking = false # resets check
			$WalkStreamer.stop() # stops the streamer
			unit_anim.play("OutlawFighterIdle") # plays the idle animation otherwise
			$NL_Heavy/HeavyAnim.play("HeavyDefenseUnitIdle")

	if unit_anim.current_animation == "OutlawFighterRun": # when the worker is playing the walk animation the particles are emitted
		$UnitBody/Armature/Skeleton3D/BoneAttachment3D2/GPUParticles3D.emitting = true # starts particles
		$OutlawGunVehicleBaked/OL_GunVehicleWheels2/WheelsBake/Particles.emitting = true
		$OutlawGunVehicleBaked/OL_GunVehicleWheels2/WheelsBake/Particles2.emitting = true
		$OutlawGunVehicleBaked/OL_GunVehicleWheels/WheelsBake/Particles.emitting = true
		$OutlawGunVehicleBaked/OL_GunVehicleWheels/WheelsBake/Particles2.emitting = true
		
		$OutlawGunVehicleBaked/OL_GunVehicleWheels2/AnimationPlayer.play("WheelRotation")
		$OutlawGunVehicleBaked/OL_GunVehicleWheels/AnimationPlayer.play("WheelRotation")
	else: #  when walking stops the particles stop spawning
		$UnitBody/Armature/Skeleton3D/BoneAttachment3D2/GPUParticles3D.emitting = false # stops particles
		$OutlawGunVehicleBaked/OL_GunVehicleWheels2/WheelsBake/Particles.emitting = false
		$OutlawGunVehicleBaked/OL_GunVehicleWheels2/WheelsBake/Particles2.emitting = false
		$OutlawGunVehicleBaked/OL_GunVehicleWheels/WheelsBake/Particles.emitting = false
		$OutlawGunVehicleBaked/OL_GunVehicleWheels/WheelsBake/Particles2.emitting = false

# when an object leaves the unit's detection range
func _on_area_3d_body_exited(body):
	if body.is_in_group("FowObject") and faction == Global.player_faction:
		body.fowExit(self) # updates the object's fow detection
	if nearby_enemies.has(body):
		nearby_enemies.erase(body) # removes the object from the list of nearby enemies if it was in the list
		if faction != Global.player_faction and (body.getType() == "worker" or body.getType() == "combat"):
			Global.removeKnownTarget(body) # attempts to remove the body from the AI's list of known targets

# re-enables attack when the attack cooldown ends
func _on_timer_timeout():
	can_attack = true

# performs specified actions when a specific animation has concluded
func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"OutlawFighterRifleFire":
			if faction == 0:
				attacking = false # lets the unit play other animations again once their attack animation has run
		"OutlawFighterDeath":
			queue_free() # deletes the unit once their death animation has finished


func _on_heavy_anim_animation_finished(anim_name):
	match anim_name:
		"HeavyDefenseUnitAttack":
			if faction == 1:
				attacking = false # lets the unit play other animations again once their attack animation has run
		"HeavyDefenseUnitDeath":
			queue_free() # deletes the unit once their death animation has finished
