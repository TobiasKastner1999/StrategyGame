extends Node2D

@onready var node_building_placer: Node3D = $placer
@onready var interface_btn_building:Button = $Button
@onready var interface_label_building: Label = $Label


var _interface_input_mode:int:
	set(new_value):
		_interface_input_mode = new_value
		
		if _interface_input_mode:
			interface_label_building.show()
			node_building_placer.enable_area()
		else:
			node_building_placer.hide()
			interface_label_building.hide()
			node_building_placer.disable_area()
			
			
var _building_placer_can_place:bool = false
var _building_placer_location:Vector3 = Vector3.ZERO



func _ready() -> void:
	interface_btn_building.pressed.connect(
		func() -> void: _interface_input_mode = 1
		)
	
	_interface_input_mode = 0




func _physics_process(delta:float) -> void:
	if _interface_input_mode == 1:
		var mouse_pos:Vector2 = get_global_mouse_position()
		var camera: Camera3D = get_viewport().get_camera_3d()

		var ray_form:Vector3 = camera.project_ray_origin(mouse_pos)
		var ray_to:Vector3 = ray_form + camera.project_ray_normal(mouse_pos) * 1000.0
		var ray_param:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_form, ray_to)
		ray_param.collision_mask = 0b10


		var raycast_result:Variant = camera.get_world_3d().get_direct_space_state().intersect_ray(ray_param)
		if raycast_result:
			if node_building_placer.transform.origin != raycast_result.position:
				node_building_placer.transform.origin = raycast_result.position
				node_building_placer.show()
				if node_building_placer.placement_check():
					_building_placer_location = raycast_result.position
					_building_placer_can_place = true
				else:
					_building_placer_can_place = false
					_building_placer_location = Vector3.ZERO
	else:
		_building_placer_can_place = false
		_building_placer_location = Vector3.ZERO


func _input(event:InputEvent) -> void:
	if Input.is_action_just_released("LeftClick"):
		var shift:bool = Input.is_action_pressed("shift")
		#print(shift)
		if _interface_input_mode == 1:
			if _building_placer_can_place and _building_placer_location != Vector3.ZERO:
				var building_packed_scene:PackedScene = load("res://buildings/building.tscn")
				var building_node:Node3D = building_packed_scene.instantiate()
				get_parent().add_child(building_node)
				building_node.transform.origin = _building_placer_location
				
				if !shift:
					_interface_input_mode = 0



