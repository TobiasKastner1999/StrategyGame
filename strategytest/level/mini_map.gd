extends CanvasLayer




var mouse_over_map = false
var map_size_x = null
var map_size_y = null
var zoom 
@onready var map = $"../Map/Floor/FloorMesh"
@onready var main_cam := $"../Camera"
@onready var unit_sprite = $MapContainer/BaseFriendly
@onready var unit_sprite2 = $MapContainer/BaseEnemy
@onready var cam_sprite = $MapContainer/Cam
@onready var tank = $"../Unit"


func _ready():

	Global.list[0] = {"positionX" : tank.position.x ,"positionY": tank.position.y,  "faction" : 0 ,"id": tank ,"dot" : $MapContainer/Tank, "worker" : tank}
	Global.list_soldiers[0] = {"positionX" : tank.position.x ,"positionY": tank.position.y,  "faction" : 0 ,"id": tank ,"dot" : $MapContainer/Tank, "soldier" : tank}
	
	#sets the positions of the hqs on the minimap
	unit_sprite.position = Vector2($"../HQFriendly".position.x, $"../HQFriendly".position.z)
	unit_sprite2.position = Vector2($"../HQEnemy".position.x, $"../HQEnemy".position.z)
	
	
	#visualizes the zoom 
	zoom = main_cam.position.y

# when the mouse enters the area of minimap the var turns true and if you click the camera moves to the position given
#via a characterbody2d that is constantly following the mouse
func _process(delta):
	
	
	
	var dot = load("res://level/dot.tscn").instantiate()
	
	dot_for_worker(dot)
	dot_for_soldier(dot)
	minimap_zoom()
	minimap_limits()
	minimap_clickable()




func dot_for_worker(dot):
	for i in Global.list.size():
		if i != null and Global.list[i]["dot"] == null:
			if Global.list[i]["faction"] == 0:
				add_unit_blue(dot)
			else:
				add_unit_red(dot)
			
			
		Global.list[i]["dot"].position = Vector2(Global.list[i]["positionX"], Global.list[i]["positionY"])


func dot_for_soldier(dot):
	for i in Global.list_soldiers.size():
		if i != null and Global.list_soldiers[i]["dot"] == null:
			if Global.list_soldiers[i]["faction"] == 0:
				add_unit_blue_soldier(dot)
			else:
				add_unit_red_soldier(dot)
			
		Global.list_soldiers[i]["dot"].position = Vector2(Global.list_soldiers[i]["positionX"], Global.list_soldiers[i]["positionY"])


func add_unit_blue(dot):
	for i in Global.list.size():
		if i != null and Global.list[i]["dot"] == null:
			if Global.list[i]["faction"] == 0:
				dot.texture = load("res://assets/blue_dot.png")
				Global.list[i]["dot"] = dot
				$MapContainer/workers.add_child(dot)

func add_unit_blue_soldier(dot):
	for i in Global.list_soldiers.size():
		if i != null and Global.list_soldiers[i]["dot"] == null:
			if Global.list_soldiers[i]["faction"] == 0:
				dot.texture = load("res://assets/blue_dot.png")
				Global.list_soldiers[i]["dot"] = dot
				$MapContainer/workers.add_child(dot)

func add_unit_red(dot):
	for i in Global.list.size():
		if i != null and Global.list[i]["dot"] == null:
			if Global.list[i]["faction"] == 1:
				dot.texture = load("res://assets/red_dot.png")
				Global.list[i]["dot"] = dot
				$MapContainer/workers.add_child(dot)

func add_unit_red_soldier(dot):
	for i in Global.list_soldiers.size():
		if i != null and Global.list_soldiers[i]["dot"] == null:
			if Global.list_soldiers[i]["faction"] == 1:
				dot.texture = load("res://assets/red_dot.png")
				Global.list_soldiers[i]["dot"] = dot
				$MapContainer/workers.add_child(dot)

func minimap_limits():
	#limitations for the cam sprite so it cant leave the minimap
	if not cam_sprite.position.x <= -250 and not cam_sprite.position.x >= 250:
		cam_sprite.position.x = main_cam.position.x
	if cam_sprite.position.x <= -250:
		cam_sprite.position.x = -249
	if cam_sprite.position.x >= 250:
		cam_sprite.position.x = 249


	if not cam_sprite.position.y <= -250 and not cam_sprite.position.y >= 250:
		cam_sprite.position.y = main_cam.position.z
	if cam_sprite.position.y <= -250:
		cam_sprite.position.y = -249
	if cam_sprite.position.y >= 250:
		cam_sprite.position.y = 249

func minimap_zoom():
	#scale the vision sprite when cam zooms in/oout
	if main_cam.position.y != zoom:
		if main_cam.position.y >= zoom:
			cam_sprite.scale +=Vector2(0.1, 0.1)
			zoom = main_cam.position.y
	if main_cam.position.y != zoom:
		if main_cam.position.y <= zoom:
			cam_sprite.scale -=Vector2(0.1, 0.1)
			zoom = main_cam.position.y

func minimap_clickable():
	if $MapContainer/CharacterBody2D.position.x >= -250 and  $MapContainer/CharacterBody2D.position.x <= 250 and $MapContainer/CharacterBody2D.position.y >= -250 and $MapContainer/CharacterBody2D.position.y <= 250:
		mouse_over_map = true
	else:
		mouse_over_map = false
	if mouse_over_map == true and Input.is_action_just_pressed("LeftClick"):
		
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		main_cam.position.x = $MapContainer/CharacterBody2D.position.x
		main_cam.position.z = $MapContainer/CharacterBody2D.position.y
