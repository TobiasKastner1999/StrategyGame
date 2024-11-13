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
var temp = 1







func _ready():

	Global.list[0] = {"positionX" : tank.position.x ,"positionY": tank.position.y,  "faction" : 0 ,"id": tank ,"dot" : $MapContainer/Tank, "worker" : tank}

	
	#sets the positions of the hqs on the minimap
	unit_sprite.position = Vector2($"../HQFriendly".position.x, $"../HQFriendly".position.z)
	unit_sprite2.position = Vector2($"../HQEnemy".position.x, $"../HQEnemy".position.z)
	
	
	#visualizes the zoom 
	zoom = main_cam.position.y

# when the mouse enters the area of minimap the var turns true and if you click the camera moves to the position given
#via a characterbody2d that is constantly following the mouse
func _process(delta):
	
	
	
	var dot = load("res://level/dot.tscn").instantiate()
	




	for i in Global.list.size():
		if i != null and Global.list[i]["dot"] == null:
			if Global.list[i]["faction"] == 0:
				add_unit_blue(dot)
			else:
				add_unit_red(dot)
			
			
		Global.list[i]["dot"].position = Vector2(Global.list[i]["positionX"], Global.list[i]["positionY"])

	
	if $MapContainer/CharacterBody2D.position.x >= -250 and  $MapContainer/CharacterBody2D.position.x <= 250 and $MapContainer/CharacterBody2D.position.y >= -250 and $MapContainer/CharacterBody2D.position.y <= 250:
		mouse_over_map = true
	else:
		mouse_over_map = false
	if mouse_over_map == true and Input.is_action_just_pressed("LeftClick"):
		
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		main_cam.position.x = $MapContainer/CharacterBody2D.position.x
		main_cam.position.z = $MapContainer/CharacterBody2D.position.y






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

#scale the vision sprite when cam zooms in/oout
	if main_cam.position.y != zoom:
		if main_cam.position.y >= zoom:
			cam_sprite.scale +=Vector2(0.1, 0.1)
			zoom = main_cam.position.y
	if main_cam.position.y != zoom:
		if main_cam.position.y <= zoom:
			cam_sprite.scale -=Vector2(0.1, 0.1)
			zoom = main_cam.position.y


func add_unit(dot):
	
	for i in Global.list:
		if Global.list[i]["dot"] == null:
			Global.list[i]["dot"] = dot
			
			print(Global.list[i]["dot"])

func add_unit_blue(dot):
	
	for i in Global.list.size():
		if i != null and Global.list[i]["dot"] == null:
			if Global.list[i]["faction"] == 0:
				dot.texture = load("res://assets/blue_dot.png")
				Global.list[i]["dot"] = dot
				$MapContainer/workers.add_child(dot)


func add_unit_red(dot):
	for i in Global.list.size():
		if i != null and Global.list[i]["dot"] == null:
			if Global.list[i]["faction"] == 1:
				dot.texture = load("res://assets/red_dot.png")
				Global.list[i]["dot"] = dot
				$MapContainer/workers.add_child(dot)


#activates when mouse is over the minimap
#func _on_area_2d_mouse_entered():
	#mouse_over_map = true
#
#
#deactivates when mouse is over the minimap
#func _on_area_2d_mouse_exited():
	#mouse_over_map = false


