extends Node3D

@onready var area:Area3D = $Area3D
@onready var area_coll:CollisionShape3D = $Area3D/CollisionShape3D
@onready var model: MeshInstance3D = $preview


func model_green() -> void:
	model.set("instance_shader_parameters/instance_color_01",Color("26bf3664"))

func model_red() -> void:
	model.set("instance_shader_parameters/instance_color_01",Color("bf262964"))


func enable_area()->void:area_coll.disabled = false
func disable_area()->void:area_coll.disabled = true

func placement_check() -> bool:
	model_red()
	
	if area.has_overlapping_bodies():
		print("geht nicht")
		return false

	var area_collshape:BoxShape3D = area_coll.get_shape()
	var area_size:Vector3 = area_collshape.size * 0.5
	var points_to_check:Array = [
		area_coll.global_transform.origin + Vector3(area_size.x,-area_size.y,area_size.z),
		area_coll.global_transform.origin + Vector3(area_size.x,-area_size.y,-area_size.z),
		area_coll.global_transform.origin + Vector3(-area_size.x,-area_size.y,-area_size.z),
		area_coll.global_transform.origin + Vector3(-area_size.x,-area_size.y,area_size.z)]
		
	var y_distances:Array = []
	
	var i:int = 0
	for point in points_to_check:
		var ray_from:Vector3 = points_to_check[i]
		var ray_to:Vector3 = ray_from + Vector3(0, -20, 0)
		var ray_param:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
		ray_param.collision_mask = 0b10
		
		var raycast_result:Variant = get_world_3d().get_direct_space_state().intersect_ray(ray_param)
		if raycast_result:
			var y_distance:float = ray_from.y - raycast_result.position.y
			y_distances.append(y_distance)
			
		else:
			print("raycast falied")
			return false
		i += 1
	
	
	for y_distance in y_distances:
		if y_distance > 2.0:
			print("not plannar enough")
			return false
	print("Everything is good")
	model_green()
	return true
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
