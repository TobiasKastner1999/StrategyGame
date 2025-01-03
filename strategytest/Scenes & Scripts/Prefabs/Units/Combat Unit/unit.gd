extends CharacterBody3D

signal deleted(unit) # to tell the system the unit has been defeated

const TARGET_TYPE = "combat" # the unit's target type
const TARGET_PRIORITY = ["combat", "worker", "hq", "building"] # the unit's targeting priority based on types

var can_attack = true # can the unit currently attack (is its attack not on cooldown)?
var nearby_enemies = [] # all enemy targets that are currently within range of the unit
var active_target : PhysicsBody3D # the enemy target the unit is currently attacking
var priority_movement = false # is the unit's movement overridden by a player command
var current_observers = []

var path = [] # the path the unit is navigating on
var path_ind = 0 # the id of the unit's current path position
var destination : Vector3 # the unit's current navigation target
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
	$UnitBehaviours.runBehaviours(self, delta)
	if $".".velocity != Vector3.ZERO:
		unit_rotation()
	

# receives the path from NavAgent
func move_to(target_pos):
	
	path = navi.get_simple_path(global_transform.origin, target_pos)
	path_ind = 0

# causes the unit to take a given amount of damage
func takeDamage(damage, attacker):
	hp -= damage # subtracts the damage taken from the current hp
	$HealthBarSprite.visible = true
	$HealthbarContainer/HealthBar.value = hp # updates the health bar display
	if hp <= 0: # removes the unit if it's remaining hp is 0 or less
		Global.updateUnitCount(faction, -1)
		deleted.emit(self) # tells the system to clear remaining references to the unit
		queue_free() # then deletes the unit
	elif active_target == null or TARGET_PRIORITY.find(active_target.getType()) > TARGET_PRIORITY.find(attacker.getType()):
		priority_movement = false
		active_target = attacker # causes the unit to fight back if it does not yet have a target

# attack the unit's current target
func startAttackCooldown():
	can_attack = false # disables the unit's attack
	$AttackCooldown.start(attack_speed) # starts the attack cooldown
	$AttackAnim/AnimationPlayer.play("attack")

# sets the target's position as the movement destination
func focusAtTarget():
	if active_target != null:
		destination = active_target.global_position

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
	destination = global_position # sets the initial navigation target to the unit's own position

# sets the unit's faction to a given value
func setFaction(f : int):
	faction = f
	$UnitBody.set_surface_override_material(1, load(Global.getFactionColor(faction)))

# changes the color of the unit when selected
func select():
	$UnitBody.set_surface_override_material(1, load(Global.getSelectedFactionColor(faction)))

# changes the color of the unit when it is deselected
func deselect():
	$UnitBody.set_surface_override_material(1, load(Global.getFactionColor(faction)) )

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

func checkUnitRemoval(unit):
	if active_target == unit:
		clearAttackTarget()
	if current_observers.has(unit):
		fowExit(unit)

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

# rotates the model to face in the right direction
func unit_rotation():
	var nav = $NavAgent.get_next_path_position() # position where the worker moves next on his path to the final destination
	$UnitBody.look_at(nav) # looks at the next position
	$UnitBody.rotation.x = rad_to_deg(0) # locks the rotation of x
	$UnitBody.rotate_object_local(Vector3.UP, PI) # flips the model 


# when an object leaves the unit's detection range
func _on_area_3d_body_exited(body):
	if body.is_in_group("FowObject") and faction == Global.player_faction:
		body.fowExit(self) # updates the object's fow detection
	if nearby_enemies.has(body):
		nearby_enemies.erase(body) # removes the object from the list of nearby enemies if it was in the list

# re-enables attack when the attack cooldown ends
func _on_timer_timeout():
	can_attack = true
