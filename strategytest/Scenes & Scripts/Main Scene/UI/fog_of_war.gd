extends Control

signal fow_updated()

@onready var camera = $SubViewportContainer/SubViewport/Camera2D
@onready var viewport = $SubViewportContainer/SubViewport
@onready var fog_sprite = $SubViewportContainer/SubViewport/FogTexture
@onready var units = $SubViewportContainer/SubViewport/TrackedUnits
@onready var tick = $Tick

var dissolved_locations = []
var main_image
var main_texture
var export_texture
var map_rect
var dissolve_sprite = preload("res://Assets/fog_dissolve.png")

var units_data = {}

func _ready():
	fog_sprite.centered = false
	tick.timeout.connect(fogTick)
	tick.start()
	newFog(Rect2(0, 0, 1024, 1024))

func fogTick():
	processUnitData()
	dissolveForUnits()

func newFog(new_rect):
	map_rect = new_rect
	viewport.size = map_rect.size
	(viewport.get_parent() as SubViewportContainer).size = map_rect.size
	camera.position = Vector2.ZERO + map_rect.size * 0.5
	
	main_image = Image.create(int(map_rect.size.x), int(map_rect.size.y), false, Image.FORMAT_RGBA8)
	main_image.fill(Color(0.0, 0.0, 0.0, 1.0))
	updateTexture()

func updateTexture():
	main_texture = ImageTexture.create_from_image(main_image)
	fog_sprite.set_texture(main_texture)
	
func dissolveFog(dissolve_position, dissolve_image):
	var used_rect = dissolve_image.get_used_rect()
	dissolve_position -= used_rect.size * 0.5
	
	var map_pos = map_rect.position + dissolve_position
	main_image.blend_rect(dissolve_image, used_rect, dissolve_position)
	
	updateTexture()

func processUnitData():
	# { unit_id : [tracked_node, sprite_node]}
	for unit_id in units_data.key():
		var unit_data = units_data[unit_id]
		var pos_to_2D = Vector2(unit_data[0].global_position.x, unit_data[0].global_position.y)
		unit_data[1].set_position(pos_to_2D)

func dissolveForUnits():
	for fow_sprite in units.get_children():
		var sprite_image = fow_sprite.get_texture().get_image()
		var dissolve_position = fow_sprite.position
		dissolveFog(dissolve_position, sprite_image)
