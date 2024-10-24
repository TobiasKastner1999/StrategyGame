extends Node3D

var start_selection_position =  Vector2()
var mouse_click_collider_3d_result
var raycast_mouse_click_3d_result
var mouse_position
var selection = []
var new_selection = []
var focus_fire_target_collider
var side_bar_mouse_entered = false
var double_click = false
@onready var camera = $Camera
@onready var selection_box_2d = $SelectionBox
@onready var mouse_raycast_group = get_tree().get_nodes_in_group("MouseRaycast")
@onready var mouse_raycast = mouse_raycast_group[0]

func _physics_process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var window_size = get_viewport().get_visible_rect().size

# camera movement when mouse near window border or WASD
	if mouse_pos.x < 10:
		$".".position.x -= 0.5
	elif mouse_pos.x > window_size.x - 10:
		$".".position.x += 0.5
	if mouse_pos.y < 10:
		$".".position.z -= 0.5
	elif mouse_pos.y > window_size.y - 10:
		$".".position.z += 0.5

	if Input.is_action_pressed("front"):
		$".".position.z -= 0.5
	if Input.is_action_pressed("back"):
		$".".position.z += 0.5
	if Input.is_action_pressed("left"):
		$".".position.x -= 0.5
	if Input.is_action_pressed("right"):
		$".".position.x += 0.5

# deselects the units on click that are not in dragged box
	mouse_position = get_viewport().get_mouse_position()
	if Input.is_action_just_pressed("LeftClick") and Input.is_action_pressed("LeftClick"):
		if $DoubleClickTimer.time_left > 0:
			double_click = true
		$DoubleClickTimer.start()
		selection_box_2d.start_selection_position = mouse_position
		start_selection_position = mouse_position
		for selected in selection:
			if selected != null:
				selected.deselect()

# selects the units inside the box
	if Input.is_action_pressed("LeftClick"):
		selection_box_2d.mouse_position = mouse_position
		selection_box_2d.is_visible = true
	else:
		selection_box_2d.is_visible = false
	
	if Input.is_action_just_released("LeftClick"):
		if double_click and $DoubleClickTimer.time_left > 0:
			selectType()
		else:
			selectUnits()
	
	# instructs the selected units to move to a given position
	if Input.is_action_just_pressed("Rightclick") && selection.size() != 0:
		raycastMouseClick() # checks for the map position the player clicked on
		var unit = getUnitUnderMouse() # checks if the player clicked on a unit
		for selected in selection:
			if selected.SR == false:
				return
			elif unit != null: 
				selected.setAttackTarget(unit) # if the player clicked on a unit, instructs the selection to attack it
			else:
				selected.setTargetPosition(raycast_mouse_click_3d_result) # otherwise, instructs the selection to move to the clicked position

# zoom in or out with mousewheel
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				$".".position.y -= 2
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				$".".position.y += 2

# function to select and replace the old selection
func selectUnits():
	new_selection = []
	if mouse_position.distance_to(start_selection_position) < 16:
		var u = getUnitUnderMouse()
		if u != null:
			new_selection.append(u)
	else:
		new_selection = getUnitsInBox(start_selection_position, mouse_position)
	if new_selection.size() != 0:
		for selected in new_selection:
			selected.select()
		selection = new_selection

func selectType():
	selectUnits()
	if selection.size() == 1:
		new_selection = []
		for unit in selection[0].get_parent().get_children():
			new_selection.append(unit)
			unit.select()
		selection = new_selection

# call the units that are under the mouse that are selectable
func getUnitUnderMouse():
	raycastFromMouse()
	var result = mouse_click_collider_3d_result
	if result != null && result.is_in_group("Selectable"):
		return result

# makes a 3d box to select units inside
func getUnitsInBox(top_left, bottom_right):
	if top_left.x > bottom_right.x:
		var temp = top_left.x
		top_left.x = bottom_right.x
		bottom_right.x = temp
	if top_left.y > bottom_right.y:
		var temp = top_left.y
		top_left.y = bottom_right.y
		bottom_right.y = temp
	var box = Rect2(top_left, bottom_right - top_left)
	selection = []
	for selected in get_tree().get_nodes_in_group("Selectable"):
		if box.has_point(camera.unproject_position(selected.global_transform.origin)):
			selection.append(selected)
	return selection

# functions create raycasts to form the 3d box for selection
func raycastMouseClick():
	var space_state = get_world_3d().direct_space_state
	var raycast_origin = camera.project_ray_origin(mouse_position)
	var raycast_target = raycast_origin + camera.project_ray_normal(mouse_position) * 5000
	var physics_raycast_query = PhysicsRayQueryParameters3D.create(raycast_origin, raycast_target)
	var raycast_result = space_state.intersect_ray(physics_raycast_query)
	if raycast_result.is_empty():
		return
	else:
		raycast_mouse_click_3d_result = raycast_result["position"]

func raycastFromMouse():
	var space_state = get_world_3d().direct_space_state
	var raycast_origin = camera.project_ray_origin(mouse_position)
	var raycast_target = raycast_origin + camera.project_ray_normal(mouse_position) * 5000
	var physics_raycast_query = PhysicsRayQueryParameters3D.create(raycast_origin, raycast_target)
	var raycast_result = space_state.intersect_ray(physics_raycast_query)
	if raycast_result.is_empty():
		return
	else:
		mouse_click_collider_3d_result = raycast_result["collider"]

func raycastNodePosition():
	var space_state = get_world_3d().direct_space_state 	
	var mouse_position = get_viewport().get_mouse_position()
	var raycast_origin = camera.project_ray_origin(mouse_position)
	var raycast_target = raycast_origin + camera.project_ray_normal(mouse_position) * 5000
	mouse_raycast.target_position = Vector3(raycast_target)

func _on_side_bar_control_mouse_entered():
	side_bar_mouse_entered = true

func _on_side_bar_control_mouse_exited():
	side_bar_mouse_entered = false
