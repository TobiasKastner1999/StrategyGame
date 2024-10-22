extends CharacterBody3D


const SPEED = 12
const JUMP_VELOCITY = 4.5
var SR 
var path = []
var path_ind = 0
var HP = 4
var go_to = Vector3.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var navi: NavigationAgent3D = $NavAgent



func _ready():
	pass

func _process(delta):
	pass


func _physics_process(delta):

#gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

#sets the movement of the unit and stops when close to goal
	navi.target_position = go_to
	var dir = navi.get_next_path_position() - global_position
	dir = dir.normalized()
	velocity = velocity.lerp(dir *SPEED, 10 * delta)
	if position.distance_to(go_to) < 1:
		velocity = Vector3.ZERO

	move_and_slide()
	
	
#receives the path from NavAgent
func move_to(target_pos):
	path = navi.get_simple_path(global_transform.origin, target_pos)
	path_ind = 0

#changes the color of the unit when selected or deselected
func select():
	print("selected")
	$UnitBody.material_override = load("res://units/new_standard_material_3d_gelb.tres")
func deselect():
	print("deselected")
	$UnitBody.material_override = load("res://units/new_standard_material_3d_weiß.tres")
	
#sets the position the NavAgent will move to
func set_target_position(target):
	go_to = target

#combat funtions when enemy unit enters range the timer starts and ticks damage to the unit 
#when HP is 0 the unit is deleted
func _on_area_3d_body_entered(body):
	if body.is_in_group("Team2"):
		$DamageTimer.start()

func _on_area_3d_body_exited(body):
	$DamageTimer.stop()


func _on_timer_timeout():
	HP -= 1
	$HealthbarContainer/HealthBar.value -= 25
	if HP == 1:
		queue_free()
