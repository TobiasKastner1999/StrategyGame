extends CharacterBody3D

var SR 
const SPEED = 12
const JUMP_VELOCITY = 4.5
var path = []
var path_ind = 0
@onready var nav = get_parent()
var save_delta
var go_to = Vector3.ZERO
@onready var navi: NavigationAgent3D = $NavigationAgent3D


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_ind = 0
	


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

		save_delta = delta
	
	navi.target_position = go_to
	
	var dir = navi.get_next_path_position() - global_position
	dir = dir.normalized()
	
	velocity = velocity.lerp(dir *SPEED, 10 * save_delta)
	if position.distance_to(go_to) < 1:
		velocity = Vector3.ZERO

	#if path_ind < path.size():
		#var move_vec = (path[path_ind]-global_transform.origin)
		#if move_vec.legnth()< 0.1:
			#path_ind += 1
		#else:
			#move_and_slide() 
	move_and_slide()
	
func select():
	print("selected")
	$MeshInstance3D.material_override = load("res://new_standard_material_3d_gelb.tres")
func deselect():
	print("deselected")
	$MeshInstance3D.material_override = load("res://new_standard_material_3d_weiß.tres")
	
func set_target_position(target):
	go_to = target
	
	

	#
	#
	#navi.target_position = target
	#var next_path_pos: Vector3 = navi.get_next_path_position()
	#var dir = next_path_pos
	#
	#dir.y = 0
	#velocity = velocity.direction_to(dir)
	
	
	
	#velocity = global_position.direction_to(target) * SPEED
	#if position != target: 
		#position = position.move_toward(target,save_delta* SPEED)

	#if position.distance_to(target) < 10:
		#var direction = (target - global_position).normalized()
		#velocity = direction * SPEED
