extends CanvasLayer

var mouse_over_map = false # value for checking if mouse is over the minimap
var zoom # value for the camerazoom
@onready var mouse = $MarginContainer/MouseIndicator # characterbody that will follow the mouse
@onready var main_cam := $"../CameraBody" # camera of main scene
@onready var unit_sprite = $MarginContainer/BaseFriendly # HQ Blue
@onready var unit_sprite2 = $MarginContainer/BaseEnemy # HQ Red
@onready var cam_sprite = $MarginContainer/Cam # Cam indicator sprite
@onready var tank = $"../HQBlue" # test unit

func _ready():
	# sets the positions of the hqs on the minimap
	unit_sprite.position = Vector2($"../HQBlue".position.x, $"../HQBlue".position.z)
	unit_sprite2.position = Vector2($"../HQRed".position.x, $"../HQRed".position.z)
	
	# visualizes the zoom 
	zoom = main_cam.position.y

func _process(_delta):
	# first entry -> test unit
	Global.list[0] = {"positionX" : tank.position.x ,"positionY": tank.position.y,  "faction" : 0 ,"id": tank ,"dot" : $MarginContainer/Tank , "worker" : tank, "visibility" : false}
	# sprite to add when units spawns
	var dot = load("res://Scenes & Scripts/Main Scene/UI/dot.tscn").instantiate()
	
	# minimap functions
	dot_for_worker(dot)
	delete_dot()
	minimap_zoom()
	minimap_limits()
	minimap_clickable()
	check_visibility()

# spawns a dot on the minimap based on faction and add the value to the dictionary
func dot_for_worker(dot):
	for i in Global.list.size():
		if i != null and Global.list[i]["dot"] == null:
			if Global.list[i]["faction"] == 0:
				add_unit_blue(dot)
			else:
				add_unit_red(dot)
			
		if Global.list[i]["dot"] != null:
			Global.list[i]["dot"].position = Vector2(Global.list[i]["positionX"], Global.list[i]["positionY"])

# sets the texture blue and spawns the dot
func add_unit_blue(dot):
	for i in Global.list.size():
		if i != null and Global.list[i]["dot"] == null:
			if Global.list[i]["faction"] == 0:
				dot.texture = load("res://Assets/UI/UnitBlue.png")
				if Global.list[i]["worker"] != null and Global.list[i]["worker"].is_in_group("Structure"):
					dot.texture = load("res://Assets/UI/BuildingBlue.png")
					dot.scale.x = 0.7
					dot.scale.y = 0.7
				Global.list[i]["dot"] = dot
				$MarginContainer/Dots.add_child(dot)

# checks for the visibility and sets the dots accordingly
func check_visibility():
	for i in Global.list.size(): # iterates through list
		if i != null and Global.list[i]["worker"] != null and Global.list[i]["worker"].visible == false: # checks if the unit of the entry is visible
			Global.list[i]["dot"].visible = false # sets the dot invisible
		if i != null and Global.list[i]["worker"] != null and Global.list[i]["worker"].visible == true: # checks if the unit of the entry is visible
			Global.list[i]["dot"].visible = true # sets the dot visible
		if $"../HQBlue".visible == false: # checks the Blue HQ
			$MarginContainer/BaseFriendly.visible = false # sets the dot invisible
		else: 
			$MarginContainer/BaseFriendly.visible = true # sets the dot visible
		if $"../HQRed".visible == false: # checks the Red HQ
			$MarginContainer/BaseEnemy.visible = false # sets the dot invisible
		else: 
			$MarginContainer/BaseEnemy.visible = true # sets the dot visible

# sets the texture red and spawns the dot
func add_unit_red(dot):
	for i in Global.list.size():
		if i != null and Global.list[i]["dot"] == null:
			if Global.list[i]["faction"] == 1:
				Global.list[i]["dot"] = dot
				dot.texture = load("res://Assets/UI/UnitRed.png")
				if Global.list[i]["worker"] != null and Global.list[i]["worker"].is_in_group("Structure"):
					dot.texture = load("res://Assets/UI/BuildingRed.png")
					dot.scale.x = 0.7
					dot.scale.y = 0.7
				$MarginContainer/Dots.add_child(dot)

# when unit disappears delete the dot on minimap
func delete_dot():
	for i in Global.list:
		if Global.list[i]["worker"] == null:
			Global.list[i]["dot"].texture = null

# limitations for the cam sprite so it cant leave the minimap
func minimap_limits():
	# limits for the cam sprite on the x-axis 
	if not cam_sprite.position.x <= -200 and not cam_sprite.position.x >= 200:
		cam_sprite.position.x = main_cam.position.x
	if cam_sprite.position.x <= -200:
		cam_sprite.position.x = -199
	if cam_sprite.position.x >= 200:
		cam_sprite.position.x = 199
	# limits for the cam sprite on the y-axis 
	if not cam_sprite.position.y <= -200 and not cam_sprite.position.y >= 200:
		cam_sprite.position.y = main_cam.position.z
	if cam_sprite.position.y <= -200:
		cam_sprite.position.y = -199
	if cam_sprite.position.y >= 200:
		cam_sprite.position.y = 199

# scale the vision sprite when cam zooms in/oout
func minimap_zoom():
	if main_cam.position.y != zoom:
		if main_cam.position.y >= zoom:
			cam_sprite.scale +=Vector2(0.1, 0.1)
			zoom = main_cam.position.y
	if main_cam.position.y != zoom:
		if main_cam.position.y <= zoom:
			cam_sprite.scale -=Vector2(0.1, 0.1)
			zoom = main_cam.position.y

func minimap_clickable():
	# when the mouse enters the area of minimap the var turns true and if you click the camera moves to the position given
	# via a characterbody2d that is constantly following the mouse and
	# limit the minimap clickrange
	if mouse.position.x >= -200 and  mouse.position.x <= 200 and mouse.position.y >= -200 and mouse.position.y <= 200:
		mouse_over_map = true
	else:
		mouse_over_map = false
	# moves the indicatorsprite to the mouse position
	if mouse_over_map == true and Input.is_action_just_pressed("LeftClick"):
		var _mouse_pos: Vector2 = get_viewport().get_mouse_position()
		main_cam.position.x = mouse.position.x
		main_cam.position.z = mouse.position.y

# overlays a new fog texture onto the minimap
func setFogTexture(new_texture):
	var fow = $MarginContainer/FogOfWar
	fow.set_texture(new_texture)
	var scale_factor = 428.197 / (float)(new_texture.get_height()) # determines the factor by which the new texture might be oversized
	fow.scale = Vector2(scale_factor, scale_factor) # sets the scale to remain within bounds
