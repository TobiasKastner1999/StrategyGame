extends Node3D

@onready var area: Area3D = $PreviewArea
@onready var area_coll: CollisionShape3D = $PreviewArea/PreviewColl
@onready var model: MeshInstance3D = $Preview

# changes colors when building can/cant be placed
func model_green() -> void:
	model.set("instance_shader_parameters/instance_color_01", Color("26bf3664"))

func model_red() -> void:
	model.set("instance_shader_parameters/instance_color_01", Color("bf262964"))

# enables or disables the Collision of the previewarea
func enable_area() -> void:
	area_coll.disabled = false

func disable_area() -> void:
	area_coll.disabled = true

# logic for building placer to check if ground is even
func placement_check() -> bool:
	model_red()
	
	# cant place when obstacles are in the way
	if area.has_overlapping_bodies() or Global.crystals < Global.BUILDING_COST:
		return false

# sets the check area to be the same size as the building
	var area_collshape : BoxShape3D = area_coll.get_shape()
	var area_size : Vector3 = area_collshape.size * 0.5
	var points_to_check : Array = [
		area_coll.global_transform.origin + Vector3(area_size.x,-area_size.y,area_size.z),
		area_coll.global_transform.origin + Vector3(area_size.x,-area_size.y,-area_size.z),
		area_coll.global_transform.origin + Vector3(-area_size.x,-area_size.y,-area_size.z),
		area_coll.global_transform.origin + Vector3(-area_size.x,-area_size.y,area_size.z)]
	var y_distances:Array = []
	
	# interation through array with a raycast to check if building can be placed
	var i : int = 0
	for point in points_to_check:
		var ray_from : Vector3 = points_to_check[i]
		var ray_to : Vector3 = ray_from + Vector3(0, -20, 0)
		var ray_param : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
		ray_param.collision_mask = 0b10
		
		var raycast_result : Variant = get_world_3d().get_direct_space_state().intersect_ray(ray_param)
		if raycast_result:
			var y_distance : float = ray_from.y - raycast_result.position.y
			y_distances.append(y_distance)
			
		else:
			return false
		i += 1
	
	# checks if the ground is even
	for y_distance in y_distances:
		if y_distance > 2.0:
			return false
	
	# sets the model green when everything is fine
	model_green()
	return true

