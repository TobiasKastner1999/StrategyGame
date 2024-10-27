extends CharacterBody3D

signal deleted(worker) # to tell the system that the worker has been removed

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MAX_HP = 2.0
var faction = 0
var SR
var dir = Vector3()
var path = []
var path_ind = 0
var go_to = Vector3.ZERO
var crystal = 0
var known_resources = []
var target_resource
var priority_movement = false
var done = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var hp = MAX_HP
@onready var navi : NavigationAgent3D = $NavAgent
@onready var hq = $".."

func _ready():
	$HealthbarContainer/HealthBar.max_value = MAX_HP # adjusts the health bar display to this unit's maximum hp
	$HealthbarContainer/HealthBar.value = hp

func _physics_process(delta):
# gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if !priority_movement:
		if crystal != 0:
			if global_position.distance_to(hq.global_position) < 4:
				crystal = 0
				Global.crystals += 1
				done = false
			else:
				go_to = hq.global_position
	
		elif target_resource != null:
			if global_position.distance_to(target_resource.global_position) <= 3 and done == false:
				done = true
				target_resource.get_parent().get_parent().takeResource()
				crystal = 1
				target_resource = null
			else:
				go_to = target_resource.global_position
	
		else:
			var closest_distance
			var closest_resource
			for res in known_resources:
				if is_instance_valid(res):
					if closest_distance == null or global_position.distance_to(res.global_position) < closest_distance:
						closest_distance = global_position.distance_to(res.global_position)
						closest_resource = res
			if closest_resource != null:
				target_resource = closest_resource
	
	# sets the movement of the unit and stops when close to goal
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
	$HealthbarContainer/HealthBar.value = hp # updates the health bar display
	if hp <= 0: # removes the worker if it's remaining hp is 0 or less
		deleted.emit(self) # tells the system to clear remaining references to the worker
		queue_free() # then deletes the worker

func setAttackTarget(unit):
	pass

# sets the worker's faction to a given value
func setFaction(f : int):
	faction = f

# returns the worker's current faction
func getFaction():
	return faction

# changes the color of the unit when selected or deselected
func select():
	$WorkerBody.material_override = load("res://units/new_standard_material_3d_gelb.tres")

func deselect():
	$WorkerBody.material_override = load("res://units/new_standard_material_3d_weiß.tres")

# sets the position the NavAgent will move to
func setTargetPosition(target):
	target_resource = null
	priority_movement = true
	go_to = target

func removeResourceKnowledge(resource):
	print("check received!")
	print(known_resources)
	if known_resources.has(resource):
		print("removed!")
		print(known_resources)
		known_resources.erase(resource)

func _on_range_area_body_entered(body):
	if body.is_in_group("resource"):
		known_resources.append(body)
