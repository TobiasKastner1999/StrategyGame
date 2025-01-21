extends Control

signal rebake() # calls to rebake the navmesh
signal start_game(faction) # tells the game the player has chosen a faction

var hq : Node3D

@onready var node_building_placer: Node3D = $Placer
@onready var interface_btn_building:TextureButton = $BuildingButton
@onready var interface_btn_housing:TextureButton = $HousingButton
@onready var interface_btn_wall:TextureButton = $WallButton
@onready var interface_label_building: Label = $Indicator

# seperation between normal and building mode
var interface_input_mode : int:
	set(new_value):
		interface_input_mode = new_value
		
		if interface_input_mode:
			Global.setCursor("res://Assets/UI/CursorBuilding.png")
			interface_label_building.show()
			node_building_placer.enable_area()
		else:
			Global.defaultCursor()
			node_building_placer.hide()
			interface_label_building.hide()
			node_building_placer.disable_area()

var building_placer_can_place : bool = false
var building_placer_location : Vector3 = Vector3.ZERO


# switches to buildingmode
func _ready():

	interface_btn_building.pressed.connect(func() -> void: interface_input_mode = 1)
	interface_btn_housing.pressed.connect(func() -> void: interface_input_mode = 2)
	interface_btn_wall.pressed.connect(func() -> void: interface_input_mode = 3)
	
	interface_input_mode = 0
	
	#setTexts()

func _physics_process(_delta):
	updateGamestateInfo()
	
	if interface_input_mode != 0:
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


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and interface_input_mode != 0:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				$Placer.rotation.y += rad_to_deg(PI/4)
	if event is InputEventMouseButton:
		if event.is_pressed() and interface_input_mode != 0:
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				$Placer.rotation.y -= rad_to_deg(PI/4)



# places the building with click and keeps building mode on when shift is pressed
func _input(_event):
	if Input.is_action_just_released("LeftClick"):
		
		#Input.warp_mouse(Vector2(get_global_mouse_position().x+50, get_global_mouse_position().y))
		var shift : bool = Input.is_action_pressed("shift")
		
		if interface_input_mode != 0:
			if building_placer_can_place and building_placer_location != Vector3.ZERO:
				var building_packed_scene : PackedScene
				match interface_input_mode:
					1:
						building_packed_scene = load("res://Scenes & Scripts/Prefabs/Structures/Production/building.tscn")
					2:
						building_packed_scene = load("res://Scenes & Scripts/Prefabs/Structures/Production/forge.tscn")
					3:
						building_packed_scene = load("res://Scenes & Scripts/Prefabs/Structures/Defense/wall.tscn")
				var building_node : Node3D = building_packed_scene.instantiate()
				building_node.rotation = $Placer.rotation
				get_parent().add_child(building_node)
				Sound.play_sound("res://Sounds/PlaceBuildingSound.mp3", $Placer/Preview)
				$Placer.rotation = Vector3(0,0,0)
				

				
				building_node.transform.origin = building_placer_location + Vector3(0, 1.0, 0)
				building_node.setFaction(Global.player_faction)
				building_node.building_menu.connect(get_parent()._on_building_menu)
				rebake.emit()
				Global.updateResource(Global.player_faction, 0, -Global.getConstructionCost(interface_input_mode))
				Global.updateBuildingCount(true)
				Global.add_to_list(building_node.position.x, building_node.position.z, Global.player_faction, building_node.get_instance_id(), null, building_node)
				building_placer_can_place = false
				$Placer.model_red()
				if !shift:
					interface_input_mode = 0
	
	if Input.is_action_just_pressed("Rightclick") and interface_input_mode != 0:
		interface_input_mode = 0
		$Placer/Preview.scale = Vector3(1,1,1)
		$Placer/Preview.position = Vector3(0,0,0)
		$Placer.rotation = Vector3(0,0,0)
# updates the Gamestatinfotext 
func updateGamestateInfo():
	var state_text = ""
	state_text += "[b]" + Global.getText("@state_info_units") + ":[/b] " + str(Global.getUnitCount(Global.player_faction)) + "/" + str(Global.getUnitLimit(Global.player_faction)) + "\n"
	state_text += "[b]" + Global.getText("@state_info_workers") + ":[/b]: " + hq.getWorkerNum() + "\n"
	state_text += "[b]" + Global.getText("@state_info_buildings") + ":[/b] " + str(Global.getBuildingCount())
	$ResourceTab/ResourceAmount1.text = "[center]" + str(Global.getResource(Global.player_faction, 0)) + "/" + str(Global.getMaxResource(Global.player_faction, 0)) + "\n" + "[/center]" # updates the recourse tab
	$ResourceTab/ResourceAmount2.text = "[center]" + str(Global.getResource(Global.player_faction, 1)) + "/" + str(Global.getMaxResource(Global.player_faction, 1)) + "\n" + "[/center]"# updates the recourse tab
	$GamestateInfo.text = state_text

#func setTexts():
	#$BuildingButton.text = Global.getText("@name_building_barracks")
	#$HousingButton.text = Global.getText("@name_building_forge")

# ends the game
func gameEnd(faction):
	for c in get_children():
		c.visible = false # hides all UI elements
	if faction == Global.player_faction:
		if Global.player_faction == 0:
			$EndScreen.text = Global.getText("@game_over_loss_OL") # sets end screen text if the player was defeated
			$EndScreen.setScreen(1)
		else:
			$EndScreen.text = Global.getText("@game_over_loss_NL") # sets end screen text if the player was defeated
			$EndScreen.setScreen(0)
	else:
		if Global.player_faction == 1:
			$EndScreen.text = Global.getText("@game_over_win_OL") # sets end screen text if the player won the game
			$EndScreen.setScreen(0)
		else:
			$EndScreen.text = Global.getText("@game_over_win_NL") # sets end screen text if the player won the game
			$EndScreen.setScreen(1)
	$EndScreen.visible = true # enables end screen visibility
	$EndScreen.setText()

# returns the interface's current input mode
func getInputMode():
	return interface_input_mode

func _on_faction_selection_start_game_dome():
	start_game.emit(0)

func _on_faction_selection_start_game_rebels():
	start_game.emit(1)

func _on_building_button_mouse_entered():
	$ConstructionTooltip.updateTooltip(true, 1)

func _on_building_button_mouse_exited():
	$ConstructionTooltip.updateTooltip(false, 1)

func _on_housing_button_mouse_entered():
	$ConstructionTooltip.updateTooltip(true, 2)

func _on_housing_button_mouse_exited():
	$ConstructionTooltip.updateTooltip(false, 2)


func _on_wall_button_mouse_entered():
	$ConstructionTooltip.updateTooltip(true, 3)


func _on_wall_button_mouse_exited():
	$ConstructionTooltip.updateTooltip(false, 3)
