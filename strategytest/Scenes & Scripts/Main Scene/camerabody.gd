extends CharacterBody3D


var speed = 50.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
# camera movement when mouse near window border or WASD
	var mouse_pos = get_viewport().get_mouse_position()
	var window_size = get_viewport().get_visible_rect().size
	


	var input_dir = Input.get_vector("left", "right", "front", "back")
	var direction = ($Camera.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() # sets the direction and corrects to cams current rotation 
	# sets the limts and moves the camera when mouse is on the border of the screen
	if mouse_pos.x < 10 and $".".position.x > -212: # left border
		direction = $Camera.transform.basis * Vector3(-1,0,0).normalized()
	elif mouse_pos.x > window_size.x - 10 and $".".position.x < 212: # right border
		direction = $Camera.transform.basis * Vector3(1,0,0).normalized()
	if mouse_pos.y < 10 and $".".position.z > -212: # top border
		direction = $Camera.transform.basis * Vector3(0,0,-1).normalized()
	elif mouse_pos.y > window_size.y - 10 and $".".position.z < 212: # bottom border
		direction = $Camera.transform.basis * Vector3(0,0,1).normalized()
	# moves the body
	#if $".".position.x < 140 and $".".position.x > -210 and $".".position.z > -100 and $".".position.z < 210:
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	move_and_slide()



# while rightclick is pressed the cam can spin through mouse movement
func _input(event):
	if Input.is_action_pressed("Rightclick"):
		if event is InputEventMouseMotion:
			$Camera.rotate_y(-event.relative.x * 0.002)

