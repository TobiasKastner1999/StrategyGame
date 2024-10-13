extends CharacterBody3D

var SR 
const SPEED = 12
const JUMP_VELOCITY = 4.5
var path = []
var path_ind = 0
@onready var nav = get_parent()
var save_delta



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_ind = 0
	


func _physics_process(delta):
	
	
	
	
	save_delta = delta
	if path_ind < path.size():
		var move_vec = (path[path_ind]-global_transform.origin)
		if move_vec.legnth()< 0.1:
			path_ind += 1
		else:
			move_and_slide() 
	
func select():
	print("selected")
	$MeshInstance3D.material_override = load("res://new_standard_material_3d_gelb.tres")
func deselect():
	print("deselected")
	$MeshInstance3D.material_override = load("res://new_standard_material_3d_weiß.tres")
	
func set_target_position(target):
	$".".position = target
	#velocity = global_position.direction_to(target) * SPEED
		#if position != target: position = position.move_toward(target,save_delta* SPEED)
		#if position.distance_to(target) < 10:
			#velocity = Vector3.ZERO
	#if position.distance_to(target) < 10:
		#var direction = (target - global_position).normalized()
		#velocity = direction * SPEED
