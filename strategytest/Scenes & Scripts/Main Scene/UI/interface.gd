extends Control

signal rebake() # calls to rebake the navmesh
signal start_game(faction) # tells the game the player has chosen a faction

@onready var node_building_placer: Node3D = $Placer
@onready var interface_btn_building:Button = $BuildingButton
@onready var interface_label_building: Label = $Indicator

# seperation between normal and building mode
var interface_input_mode : int:
	set(new_value):
		interface_input_mode = new_value
		
		if interface_input_mode:
			interface_label_building.show()
			node_building_placer.enable_area()
		else:
			node_building_placer.hide()
			interface_label_building.hide()
			node_building_placer.disable_area()

var building_placer_can_place : bool = false
var building_placer_location : Vector3 = Vector3.ZERO


# switches to buildingmode
func _ready() -> void:
	interface_btn_building.pressed.connect(func() -> void: interface_input_mode = 1)
	interface_input_mode = 0

func _physics_process(_delta):
	if interface_input_mode == 1:
		#raycast to place preview under mouse
		var mouse_pos : Vector2 = get_global_mouse_position()
		var camera : Camera3D = get_viewport().get_camera_3d()

		var ray_form : Vector3 = camera.project_ray_origin(mouse_pos)
		var ray_to : Vector3 = ray_form + camera.project_ray_normal(mouse_pos) * 1000.0
		var ray_param : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_form, ray_to)
		ray_param.collision_mask = 0b10

# checks the ground for placing
		var raycast_result : Variant = camera.get_world_3d().get_direct_space_state().intersect_ray(ray_param)
		if raycast_result:
			if node_building_placer.transform.origin != raycast_result.position:
				node_building_placer.transform.origin = raycast_result.position
				node_building_placer.show()
				if node_building_placer.placement_check():
					building_placer_location = raycast_result.position
					building_placer_can_place = true
				else:
					building_placer_can_place = false
					building_placer_location = Vector3.ZERO
	else:
		building_placer_can_place = false
		building_placer_location = Vector3.ZERO

# places the building with click and keeps building mode on when shift is pressed
func _input(_event):
	if Input.is_action_just_released("LeftClick"):
		var shift : bool = Input.is_action_pressed("shift")

		if interface_input_mode == 1:
			if building_placer_can_place and building_placer_location != Vector3.ZERO:
				var building_packed_scene : PackedScene = load("res://Scenes & Scripts/Prefabs/Structures/Production/building.tscn")
				var building_node : Node3D = building_packed_scene.instantiate()
				get_parent().add_child(building_node)
				building_node.transform.origin = building_placer_location + Vector3(0, 1.0, 0)
				building_node.setFaction(Global.player_faction)
				building_node.building_menu.connect(get_parent()._on_building_menu)
				rebake.emit()
				Global.updateResource(Global.player_faction, 0, -Global.BUILDING_COST)
				
				if !shift:
					interface_input_mode = 0
	
	if Input.is_action_just_pressed("Rightclick") and interface_input_mode == 1:
		interface_input_mode = 0

# ends the game
func gameEnd(faction):
	for c in get_children():
		c.visible = false # hides all UI elements
	if faction == Global.player_faction:
		$EndScreen/EndScreenText.text = "Game Over! You lost..." # sets end screen text if the player was defeated
	else:
		$EndScreen/EndScreenText.text = "Victory!" # sets end screen text if the player won the game
	$EndScreen.visible = true # enables end screen visibility

# when the player starts the game and chooses the blue faction
func _on_button_blue_pressed():
	start_game.emit(0)

# when the player starts the game and chooses the red faction
func _on_button_red_pressed():
	start_game.emit(1)