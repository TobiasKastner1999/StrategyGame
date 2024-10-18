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

	move_and_slide()
	
func select():
	print("selected")
	$MeshInstance3D.material_override = load("res://units/new_standard_material_3d_gelb.tres")
func deselect():
	print("deselected")
	$MeshInstance3D.material_override = load("res://units/new_standard_material_3d_weiß.tres")
	
func set_target_position(target):
	go_to = target
