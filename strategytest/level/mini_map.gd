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

func _ready():
	
	unit_sprite.position = Vector2($"../HQFriendly".position.x, $"../HQFriendly".position.z)
	unit_sprite2.position = Vector2($"../HQEnemy".position.x, $"../HQEnemy".position.z)
	
	
	
	zoom = main_cam.position.y
	map_size_x = map.mesh.size.x
	map_size_y = map.mesh.size.y

	$MapContainer.set_size(Vector2(map_size_x, map_size_y))
# when unit/camera move the minimap sprites follow
func _process(delta):
	
	if mouse_over_map == true and Input.is_action_just_pressed("LeftClick"):
		var mouse_pos: Vector2 = get_viewport().get_mouse_position()
		main_cam.position.x = mouse_pos.x 
		main_cam.position.z = mouse_pos.y 
		print(mouse_pos)

		print(main_cam.position)
		
	
	
	
	
	$MapContainer/Tank.position = Vector2($"../Unit".position.x, $"../Unit".position.z)
	
	
	if not cam_sprite.position.x <= -250 and not cam_sprite.position.x >= 250:
		cam_sprite.position.x = main_cam.position.x
	if cam_sprite.position.x <= -250:
		cam_sprite.position.x +=1
	if cam_sprite.position.x >= 250:
		cam_sprite.position.x -=1



	if not cam_sprite.position.y <= -250 and not cam_sprite.position.y >= 250:
		cam_sprite.position.y = main_cam.position.z
	if cam_sprite.position.y <= -250:
		cam_sprite.position.y +=1
	if cam_sprite.position.y >= 250:
		cam_sprite.position.y -=1


	if main_cam.position.y != zoom:
		if main_cam.position.y >= zoom:
			cam_sprite.scale +=Vector2(0.1, 0.1)
			zoom = main_cam.position.y
	if main_cam.position.y != zoom:
		if main_cam.position.y <= zoom:
			cam_sprite.scale -=Vector2(0.1, 0.1)
			zoom = main_cam.position.y
			
			
func add_unit(faction):
	pass


func _on_area_2d_mouse_entered():
	mouse_over_map = true


func _on_area_2d_mouse_exited():
	mouse_over_map = false


