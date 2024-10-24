extends CharacterBody3D

signal deleted(unit) # to tell the system the unit has been defeated

var can_attack = true # can the unit currently attack (is its attack not on cooldown)?
var nearby_enemies = [] # all enemy targets that are currently within range of the unit
var current_target : CharacterBody3D # the enemy target the unit is currently attacking
var priority_movement = false # is the unit's movement overridden by a player command

var path = [] # the path the unit is navigating on
var path_ind = 0 # the id of the unit's current path position
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") # the strength of the gravity affecting the unit
var SR 

@export var faction : int # which faction does this unit belong to?
@export var max_hp : float # the units maximum hit points
@export var damage_value : float # the damage the unit deals with each attack
@export var attack_range : int # the distance at which the unit can attack enemy targets
@export var attack_speed : float # the rate at which the unit attacks
@export var detection_range : float # the distance at which the unit can detect other units
@export var speed : float # the unit's movement speed

@onready var hp = max_hp # the unit's current hp, starting as its maximum hp
@onready var navi : NavigationAgent3D = $NavAgent # the navigation agent controlling the unit's movement
@onready var go_to = global_position # the global position the agent wants to navigate to

# called when the unit is first loaded
func _ready():
	if faction == 1:
		$UnitBody/EnemyIdentifier.visible = true # visually displays a ring denoting the unit as a member of the enemy faction
	$HealthbarContainer/HealthBar.max_value = max_hp # adjusts the health bar display to this unit's maximum hp
	$HealthbarContainer/HealthBar.value = hp
	$RangeArea/RangeColl.shape = $RangeArea/RangeColl.shape.duplicate()
	$RangeArea/RangeColl.shape.radius = detection_range
	$AttackAnim.mesh = $AttackAnim.mesh.duplicate()

# controls the unit's movement and other actions
func _physics_process(delta):
	# unit is affected by gravity if it is floating
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# adjusts the unit's movement and other actions if it isn't currently following a player command to move to a specific position
	if priority_movement == false:
		# if the unit is already fighting an enemy target
		if current_target != null:
			if global_position.distance_to(current_target.global_position) <= attack_range:
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
					if (min_distance == null) or (distance < min_distance):
						min_distance = distance
						intend_target = enemy # if the distance is the shortest, designates that enemy as the first target
				# if the intented target is within attack range, attempts to attack
				if min_distance <= attack_range:
					current_target = intend_target # sets the target
					if can_attack:
						attackTarget() # attacks the target if the unit's attack is available
				else:
					go_to = intend_target.global_position # if the target is outside of the attack range, moves towards the target instead
	
	# sets the movement of the unit and stops when close to goal
	if go_to != global_position:
		navi.target_position = go_to
		var dir = navi.get_next_path_position() - global_position
		dir = dir.normalized()
		velocity = velocity.lerp(dir * speed, 10 * delta)
		if position.distance_to(go_to) < (attack_range / 2):
			go_to = global_position
			velocity = Vector3.ZERO
			priority_movement = false
		move_and_slide()

# receives the path from NavAgent
func move_to(target_pos):
	path = navi.get_simple_path(global_transform.origin, target_pos)
	path_ind = 0

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
	$HealthbarContainer/HealthBar.value = hp # updates the health bar display
	if hp <= 0: # removes the unit if it's remaining hp is 0 or less
		deleted.emit(self) # tells the system to clear remaining references to the unit
		queue_free() # then deletes the unit
	elif current_target == null and nearby_enemies.size() == 0:
		current_target = attacker

# changes the color of the unit when selected or deselected
func select():
	$UnitBody.material_override = load("res://units/new_standard_material_3d_gelb.tres")

func deselect():
	$UnitBody.material_override = load("res://units/new_standard_material_3d_weiß.tres")

# sets the unit's faction to a given value
func setFaction(f : int):
	faction = f

# returns the unit's current faction
func getFaction():
	return faction

# sets the position the NavAgent will move to
func setTargetPosition(target):
	if nearby_enemies.size() != 0 or current_target != null:
		current_target = null
		priority_movement = true
	go_to = target

# attempts to set a given target as the unit's target
func setAttackTarget(target):
	if target.is_in_group("CombatTarget") and target.getFaction() != faction:
		current_target = target # sets the target if the given entity is a valid target and belongs to an enemy faction

# when a new object enters the unit's detection range
func _on_area_3d_body_entered(body):
	if body.is_in_group("CombatTarget") and body.getFaction() != faction:
		nearby_enemies.append(body) # adds the object to the list of nearby enemies if it is a valid t arget and belongs to an enemy faction

# when an object leaves the unit's detection range
func _on_area_3d_body_exited(body):
	if nearby_enemies.has(body):
		nearby_enemies.erase(body) # removes the object from the list of nearby enemies if it was in the list

# re-enables attack when the attack cooldown ends
func _on_timer_timeout():
	can_attack = true
