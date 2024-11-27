extends CharacterBody3D

signal deleted(unit) # to tell the system the unit has been defeated

const TARGET_TYPE = "combat" # the unit's target type
const TARGET_PRIORITY = ["combat", "hq", "building", "worker"] # the unit's targeting priority based on types

var can_attack = true # can the unit currently attack (is its attack not on cooldown)?
var nearby_enemies = [] # all enemy targets that are currently within range of the unit
var current_target : PhysicsBody3D # the enemy target the unit is currently attacking
var priority_movement = false # is the unit's movement overridden by a player command

var path = [] # the path the unit is navigating on
var path_ind = 0 # the id of the unit's current path position
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") # the strength of the gravity affecting the unit
var go_to# the unit's current navigation target
var SR 

var unit_type : int # the unit's type
var faction : int # which faction does this unit belong to?
var max_hp : float # the units maximum hit points
var damage_value : float # the damage the unit deals with each attack
var attack_range : float # the distance at which the unit can attack enemy targets
var attack_speed : float # the rate at which the unit attacks
var detection_range : float # the distance at which the unit can detect other units
var speed : float # the unit's movement speed

@onready var hp = max_hp # the unit's current hp, starting as its maximum hp
@onready var navi : NavigationAgent3D = $NavAgent # the navigation agent controlling the unit's movement

# controls the unit's movement and other actions
func _physics_process(delta):
	$UnitBody.rotation.x = 0 # locks unit rotation
	
	
	
	# unit is affected by gravity if it is floating
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# adjusts the unit's movement and other actions if it isn't currently following a player command to move to a specific position
	if priority_movement == false:
		# if the unit is already fighting an enemy target
		if current_target != null:
			if global_position.distance_to(current_target.global_position) <= (attack_range + current_target.getSize()):
				if can_attack:
					attackTarget() # attacks the target if it is within attack range, and the unit's attack is available
			else:
				go_to = current_target.global_position # otherwise, the unit moves towards the target
	
		else:
			# if there are any enemies nearby
			if nearby_enemies.size() > 0:
				var min_distance
				var intend_target
				for enemy in nearby_enemies:
					var distance = global_position.distance_to(enemy.global_position) # checks the distance to each enemy
					# chooses a new intended target, if the following is true:
					# no intended target has been chosen yet OR
					# the new target is of a higher target priority then the previous intended target OR
					# the new target is of the same target priority as the previous intended target, but closer to the unit
					if (min_distance == null) or (checkTargetPriority(enemy.getType()) < checkTargetPriority(intend_target.getType())) or ((distance < min_distance) and (checkTargetPriority(enemy.getType()) == checkTargetPriority(intend_target.getType()))):
						min_distance = distance
						intend_target = enemy # designates that enemy as the first target
				# if the intented target is within attack range, attempts to attack
				if min_distance <= attack_range:
					current_target = intend_target # sets the target
					if can_attack:
						attackTarget() # attacks the target if the unit's attack is available
				else:
					go_to = intend_target.global_position # if the target is outside of the attack range, moves towards the target instead
	
	# sets the movement of the unit and stops when close to goal
	if go_to != global_position:
		if navi.target_position != go_to:
			navi.target_position = go_to
		var dir = navi.get_next_path_position() - global_position
		dir = dir.normalized()
		if position.distance_to(go_to) < (attack_range / 2.0):
			go_to = global_position
			velocity = Vector3.ZERO
			priority_movement = false
		else:
			var intended_velocity = velocity.lerp(dir * speed, 10 * delta)
			navi.set_velocity(intended_velocity) # passes the intended movement velocity onto the navigation agent

# receives the path from NavAgent
func move_to(target_pos):
	path = navi.get_simple_path(global_transform.origin, target_pos)
	path_ind = 0

func unit_rotation():
	if navi.get_next_path_position() != Vector3.ZERO:
		$UnitBody.look_at(go_to)
		$UnitBody.rotation.x = 0
		$UnitBody.rotate_object_local(Vector3.UP, PI)

# returns the priority index of a given entry in the priority array
func checkTargetPriority(type : String):
	return TARGET_PRIORITY.find(type)

# attack the unit's current target
func attackTarget():
	go_to = global_position # stops the unit's movement
	current_target.takeDamage(damage_value, self) # causes target to take the unit's attack damage
	can_attack = false # disables the unit's attack
	$AttackCooldown.start(attack_speed) # starts the attack cooldown
	$AttackAnim/AnimationPlayer.play("attack")

# causes the unit to take a given amount of damage
func takeDamage(damage, attacker):
	hp -= damage # subtracts the damage taken from the current hp
	$HealthBarSprite.visible = true
	$HealthbarContainer/HealthBar.value = hp # updates the health bar display
	if hp <= 0: # removes the unit if it's remaining hp is 0 or less
		Global.updateUnitCount(faction, -1)
		deleted.emit(self) # tells the system to clear remaining references to the unit
		queue_free() # then deletes the unit
	elif current_target == null:
		priority_movement = false
		current_target = attacker # causes the unit to fight back if it does not yet have a target

# changes the color of the unit when selected
func select():
	$UnitBody.set_surface_override_material(1, load(Global.getSelectedFactionColor(faction)))

# changes the color of the unit when it is deselected
func deselect():
	$UnitBody.set_surface_override_material(1, load(Global.getFactionColor(faction)) )

# sets up the unit and its properties when it is spawned
func setUp(type):
	# sets the various properties from the given values for the unit's type
	unit_type = type
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
		2:
			$TypeIdentifier.set_surface_override_material(0, load("res://Assets/Materials/material_purple.tres"))
		3:
			$TypeIdentifier.set_surface_override_material(0, load("res://Assets/Materials/material_orange.tres"))
	
	$HealthbarContainer/HealthBar.max_value = max_hp # adjusts the health bar display to this unit's maximum hp
	$HealthbarContainer/HealthBar.value = hp
	$RangeArea/RangeColl.shape = $RangeArea/RangeColl.shape.duplicate()
	$RangeArea/RangeColl.shape.radius = detection_range
	$AttackAnim.mesh = $AttackAnim.mesh.duplicate()
	
	await get_tree().physics_frame
	go_to = global_position # sets the initial navigation target to the unit's own position

# sets the unit's faction to a given value
func setFaction(f : int):
	faction = f
	$UnitBody.set_surface_override_material(1, load(Global.getFactionColor(faction)))

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

# sets the position the NavAgent will move to
func setTargetPosition(target):
	if nearby_enemies.size() != 0 or current_target != null:
		current_target = null
		priority_movement = true
	go_to = target
	unit_rotation()
	

# checks if the unit is active
func isActive():
	if current_target != null:
		return true # returns true if the unit has a target
	else:
		return false

# checks if the unit is near a given body
func isNearBody(node):
	if $RangeArea.overlaps_body(node):
		return true
	else:
		return false

# attempts to set a given target as the unit's target
func setAttackTarget(target):
	if target.is_in_group("CombatTarget") and target.getFaction() != faction:
		current_target = target # sets the target if the given entity is a valid target and belongs to an enemy faction

# when a new object enters the unit's detection range
func _on_area_3d_body_entered(body):
	if body.is_in_group("CombatTarget") and body.getFaction() != faction:
		nearby_enemies.append(body) # adds the object to the list of nearby enemies if it is a valid t arget and belongs to an enemy faction
		if priority_movement:
			priority_movement = false
			setAttackTarget(body)

# when an object leaves the unit's detection range
func _on_area_3d_body_exited(body):
	if nearby_enemies.has(body):
		nearby_enemies.erase(body) # removes the object from the list of nearby enemies if it was in the list

# re-enables attack when the attack cooldown ends
func _on_timer_timeout():
	can_attack = true

# moves the agent on the computed safe velocity
func _on_nav_agent_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()
