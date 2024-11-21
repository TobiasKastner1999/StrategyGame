extends CanvasLayer




var mouse_over_map = false
var zoom 
@onready var mouse = $MarginContainer/MouseIndicator # characterbody that will follow the mouse
@onready var main_cam := $"../Camera" # camera of main scene
@onready var unit_sprite = $MarginContainer/BaseFriendly # HQ Blue
#@onready var unit_sprite2 = $MarginContainer/BaseEnemy # HQ Red
@onready var cam_sprite = $MarginContainer/Cam # Cam indicator sprite
@onready var tank = $"../HQBlue" # test unit


func _ready():
	# first entry -> test unit
	Global.list[0] = {"positionX" : tank.position.x ,"positionY": tank.position.y,  "faction" : 0 ,"id": tank ,"dot" : $MarginContainer/Tank , "worker" : tank}
	
	
	# sets the positions of the hqs on the minimap
	unit_sprite.position = Vector2($"../HQBlue".position.x, $"../HQBlue".position.z)
	#unit_sprite2.position = Vector2($"../HQRed".position.x, $"../HQRed".position.z)
	
	
	# visualizes the zoom 
	zoom = main_cam.position.y

# when the mouse enters the area of minimap the var turns true and if you click the camera moves to the position given
# via a characterbody2d that is constantly following the mouse
func _process(delta):
	
	
	# sprite to add when units spawns
	var dot = load("res://Scenes & Scripts/Main Scene/UI/dot.tscn").instantiate()
	
	# minimap functions
	dot_for_worker(dot)
	delete_dot()
	minimap_zoom()
	minimap_limits()
	minimap_clickable()
	#for i in Global.list:
		#print(Global.list[i]["worker"])


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
				if Global.list[i]["worker"].is_in_group("Structure"):
					dot.texture = load("res://Assets/UI/BuildingBlue.png")
					dot.scale.x = 0.7
					dot.scale.y = 0.7
				Global.list[i]["dot"] = dot
				$MarginContainer/Dots.add_child(dot)


# sets the texture red and spawns the dot
func add_unit_red(dot):
	#await get_tree().create_timer(0.1).timeout
	for i in Global.list.size():
		if i != null and Global.list[i]["dot"] == null:
			if Global.list[i]["faction"] == 1:
				Global.list[i]["dot"] = dot
				dot.texture = load("res://Assets/UI/UnitRed.png")
				if Global.list[i]["worker"].is_in_group("Structure"):
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
	
	if not cam_sprite.position.x <= -125 and not cam_sprite.position.x >= 125:
		cam_sprite.position.x = main_cam.position.x
	if cam_sprite.position.x <= -125:
		cam_sprite.position.x = -124
	if cam_sprite.position.x >= 125:
		cam_sprite.position.x = 124


	if not cam_sprite.position.y <= -125 and not cam_sprite.position.y >= 125:
		cam_sprite.position.y = main_cam.position.z
	if cam_sprite.position.y <= -125:
		cam_sprite.position.y = -124
	if cam_sprite.position.y >= 125:
		cam_sprite.position.y = 124

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

# limit the minimap clickrange and move the cam to the position on the minimap
func minimap_clickable():
	if mouse.position.x >= -125 and  mouse.position.x <= 125 and mouse.position.y >= -125 and mouse.position.y <= 125:
		mouse_over_map = true
	else:
		mouse_over_map = false
	if mouse_over_map == true and Input.is_action_just_pressed("LeftClick"):
		Sound.play_sound("res://Sounds/metal-pipe-clang.mp3")
		Sound.play_sound("res://Sounds/lego-yoda-death-sound-effect.mp3")
		
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		main_cam.position.x = mouse.position.x
		main_cam.position.z = mouse.position.y


