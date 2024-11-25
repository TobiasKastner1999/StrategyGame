extends CharacterBody2D


const SPEED = 10





func _physics_process(delta):




# characterbody follows the mouse around to track in 2d instance
	var direction = get_local_mouse_position()
	if direction:
		velocity = direction * SPEED


	move_and_slide()



