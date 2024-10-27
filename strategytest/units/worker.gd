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

# sets the movement of the unit and stops when close to goal
	navi.target_position = go_to
	var dir = navi.get_next_path_position() - global_position
	dir = dir.normalized()
	
	velocity = velocity.lerp(dir * SPEED, 10 * delta)
	if position.distance_to(go_to) < 2:
		velocity = Vector3.ZERO

# area checks all bodies inside coll and puts them into a array
# array is checked for bodies in group resource and moves the unit automatically to the resource
# resource is then collected and unit delivers the resource to the base
	if crystal != 0:
		go_to = hq.global_position
		if global_position.distance_to(hq.global_position) < 4:
			crystal = 0
			Global.crystals += 1
			done = false
	
	else:
		var list = $RangeArea.get_overlapping_bodies()
		for n in list:
			if (n.is_in_group("resource")):
				go_to = n.global_position
				if global_position.distance_to(n.global_position) <= 3 and done == false:
					done = true
					n.get_parent().get_parent().resource -=1
					crystal = 1

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
	go_to = target
