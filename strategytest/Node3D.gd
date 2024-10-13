extends Node3D



@onready var camera = $Camera3D
@onready var selectionBox2D = $SelectionBox

var startSelectionPosition =  Vector2()
var mouseClickCollider3DResult
var raycastMouseClick3DResult
var mousePosition
var selection = []
var newSelection = []
var focusFireTargetCollider
var sideBarMouseEntered = false



@onready var mouseRaycastGroup = get_tree().get_nodes_in_group("MouseRaycast")
@onready var mouseRaycast = mouseRaycastGroup[0]



func _physics_process(delta):
	mousePosition = get_viewport().get_mouse_position()
	if Input.is_action_just_pressed("LeftClick"):
		selectionBox2D.startSelectionPosition = mousePosition
		startSelectionPosition = mousePosition
		for selected in selection:
			selected.deselect()


	if Input.is_action_pressed("LeftClick"):
		selectionBox2D.mousePosition = mousePosition
		selectionBox2D.isVisible = true
	else:
		selectionBox2D.isVisible = false
	if Input.is_action_just_released("LeftClick"):
		SelectUnits()


	if Input.is_action_just_pressed("Rightclick") && selection.size() != 0:
		for selected in selection:
			if selected.SR == false:
				return
			else:
				print("yes")
				RaycastMouseClick()
				#selected.SPEED = 600
				selected.set_target_position(raycastMouseClick3DResult)
				#selected.beanSoldier.hasStopped = false
				#selected.beanSoldier.combatRange.combatTimer.stop()
				#selected.beanSoldier.combatRange.hasCombatTimerStarted = false
				#RaycastFromMouse()
				#focusFireTargetCollider = mouseClickCollider3DResult
				#if focusFireTargetCollider.is_in_group("Enemy"):
					#selected.beanSoldier.combatRange.focusFireTarget = mouseClickCollider3DResult
					#selected.beanSoldier.beanNA.set_target_position(focusFireTargetCollider.global_transform.origin)
					#print(selected.beanSoldier.combatRange.focusFireTarget.name)
				#else:
					#selected.beanSoldier.combatRange.focusFireTarget = null



func SelectUnits():
	newSelection = []
	if mousePosition.distance_to(startSelectionPosition) < 16:
		var u = GetUnitUnderMouse()
		if u != null:
			newSelection.append(u)
	else:
		newSelection = GetUnitsInBox(startSelectionPosition, mousePosition)
	if newSelection.size() != 0:
		for selected in newSelection:
			selected.select()
		selection = newSelection

		

			

func GetUnitUnderMouse():
	var result = mouseClickCollider3DResult
	if result != null && result.is_in_group("Selectable"):
		return result.collider



func GetUnitsInBox(topLeft, bottomRight):
	if topLeft.x > bottomRight.x:
		var temp = topLeft.x
		topLeft.x = bottomRight.x
		bottomRight.x = temp
	if topLeft.y > bottomRight.y:
		var temp = topLeft.y
		topLeft.y = bottomRight.y
		bottomRight.y = temp
	var box = Rect2(topLeft, bottomRight - topLeft)
	selection = []
	for selected in get_tree().get_nodes_in_group("Selectable"):
		if box.has_point(camera.unproject_position(selected.global_transform.origin)):
			selection.append(selected)
	return selection



func RaycastMouseClick():
	var spaceState = get_world_3d().direct_space_state
	var raycastOrigin = camera.project_ray_origin(mousePosition)
	var raycastTarget = raycastOrigin + camera.project_ray_normal(mousePosition) * 5000
	var physicsRaycastQuery = PhysicsRayQueryParameters3D.create(raycastOrigin, raycastTarget)
	var raycastResult = spaceState.intersect_ray(physicsRaycastQuery)
	if raycastResult.is_empty():
		return

	else:
		raycastMouseClick3DResult = raycastResult["position"]

func RaycastFromMouse():
	var spaceState = get_world_3d().direct_space_state
	var raycastOrigin = camera.project_ray_origin(mousePosition)
	var raycastTarget = raycastOrigin + camera.project_ray_normal(mousePosition) * 5000
	var physicsRaycastQuery = PhysicsRayQueryParameters3D.create(raycastOrigin, raycastTarget)
	var raycastResult = spaceState.intersect_ray(physicsRaycastQuery)

	if raycastResult.is_empty():
		return
	else:
		mouseClickCollider3DResult = raycastResult["collider"]

		

func RaycastNodePosition():
	var spaceState = get_world_3d().direct_space_state 	
	var mousePosition = get_viewport().get_mouse_position()
	var raycastOrigin = camera.project_ray_origin(mousePosition)
	var raycastTarget = raycastOrigin + camera.project_ray_normal(mousePosition) * 5000
	mouseRaycast.target_position = Vector3(raycastTarget)


func _on_side_bar_control_mouse_entered():
	sideBarMouseEntered = true

func _on_side_bar_control_mouse_exited():
	sideBarMouseEntered = false
