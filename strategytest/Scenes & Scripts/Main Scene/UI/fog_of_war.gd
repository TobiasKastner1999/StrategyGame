extends Control

signal fow_updated(new_texture) # to tell the system that the fog of war has changed

const MIN_SIZE = 0.1 # the minimum size to which a vision circle can shrink
const SHRINK_FACTOR = 0.5 # the factor by which a vision circle shrinks on each call

var stored_dissolved_positions = [] # a list of positions that have already been dissolved previously
var main_image # the fog's main image
var main_texture # the texture of the main image
var export_texture # the exported texture generated from the current fog of war
var map_rect # the rectangle of the fog of war map
var dissolve_sprite = preload("res://Assets/fog_dissolve.png") # the fog dissolve texture
var units_data = {} # the data of each tracked unit
var dying_units = [] # a list of the units that are currently in the process of dying

@onready var camera = $SubViewportContainer/SubViewport/Camera2D # the sub-scene's camera
@onready var viewport = $SubViewportContainer/SubViewport # the viewport holding the fog of war
@onready var fog_sprite = $SubViewportContainer/SubViewport/FogTexture # the sprite representing the fog of war
@onready var units = $SubViewportContainer/SubViewport/TrackedUnits # the node holding the units influencing the fog of war
@onready var tick = $Tick # the fog of war's tick timer

# called at the start of the game
func _ready():
	fog_sprite.centered = false
	tick.timeout.connect(fogTick)
	tick.start() # sets up & starts the tick timer

# called whenever the fog timer ticks
func fogTick():
	processUnitData() # updates the tracking of all units
	dissolveForUnits() # then dissolves the fog for each tracked unit
	
	exportFog() # exports the fog to the main map

# generates a new fog of war from a given rectangle
func newFog(new_rect):
	map_rect = new_rect
	map_rect.size /= 4
	viewport.size = map_rect.size # matches the viewport to the new rectangle
	(viewport.get_parent() as SubViewportContainer).size = map_rect.size
	camera.position = Vector2.ZERO + map_rect.size * 0.5 # sets the camera's position to the middle of the rectangle
	
	main_image = Image.create(int(map_rect.size.x), int(map_rect.size.y), false, Image.FORMAT_RGBA8)
	main_image.fill(Color(0.0, 0.0, 0.0, 1.0)) # creates new image for the fog of war from the rectangle
	
	updateTexture() # updates the fog of war texture with the new image
	exportFog() # exports the fog to the main map

# exports the fog to the main map
func exportFog():
	export_texture = ImageTexture.create_from_image(viewport.get_texture().get_image())
	fow_updated.emit(export_texture)

# updates the fog of war's texture
func updateTexture():
	main_texture = ImageTexture.create_from_image(main_image)
	fog_sprite.set_texture(main_texture)

# dissolves a given texture into the fog at a given position
func dissolveFog(dissolve_position, dissolve_image):
	var used_rect = dissolve_image.get_used_rect() # grabs rectangle from the image
	dissolve_position -= used_rect.size * 0.5 # sets up the correct position
	
	var map_pos = map_rect.position + dissolve_position
	main_image.blend_rect(dissolve_image, used_rect, dissolve_position) # blends the images together
	
	updateTexture() # then updates the fog of war's texture

# scales the dissolve texture to a given size
func getNewDissolveSize(new_size):
	var dissolve_image = dissolve_sprite.get_image()
	dissolve_image.resize(new_size, new_size)
	return ImageTexture.create_from_image(dissolve_image)

# adds a new tracked unit
func addUnit(unit_node):
	var new_sprite = Sprite2D.new() # sets up a new sprite
	new_sprite.set_texture(getNewDissolveSize(unit_node.detection_range * 2)) # scales the sprite size with the unit's detection radius
	units.add_child(new_sprite)
	units_data[unit_node.get_instance_id()] = [unit_node, new_sprite] # stores the unit's data
	var pos_to_2D = fog_sprite.get_rect().get_center() + Vector2(unit_node.global_position.x, unit_node.global_position.z) / 2
	new_sprite.set_position(pos_to_2D) # then moves the tracking sprite to a correctly scaled 2D position based on the unit's position

# attempts to remove a tracked unit
func attemptRemoveUnit(unit):
	if units_data.keys().has(unit.get_instance_id()): # if the given unit is actually being tracked
		dying_units.append(unit.get_instance_id()) # if it is, adds it to the list of dying units

# updates the data state for all tracked units
func processUnitData():
	# { unit_id : [tracked_node, sprite_node]}
	for unit_id in units_data.keys():
		var unit_data = units_data[unit_id] # grabs the data
		# if the unit is already dying
		if dying_units.has(unit_id):
			if unit_data[1].scale.x <= MIN_SIZE:
				units_data[unit_id][1].queue_free() # removes the associated sprite if it is below the minimum size
				units_data.erase(unit_id) # then removes the matching data
			else:
				unit_data[1].scale *= SHRINK_FACTOR # otherwise continues to shrink the sprite
		# otherwise
		else:
			var pos_to_2D = fog_sprite.get_rect().get_center() + Vector2(unit_data[0].global_position.x, unit_data[0].global_position.z) / 2 # updates the scaled 2D position
			unit_data[1].set_position(pos_to_2D) # moves the sprite to that position

# dissolves the fog of war around each tracked unit
func dissolveForUnits():
	for fow_sprite in units.get_children():
		var sprite_image = fow_sprite.get_texture().get_image()
		var store_position = Vector3i(fow_sprite.position.x, fow_sprite.position.y, fow_sprite.get_texture().get_size().x) # stores a data vector for the sprite's position & size
		
		if !store_position in stored_dissolved_positions: # if that position hasn't been dissolved already:
			var dissolve_position = fow_sprite.global_position
			dissolveFog(dissolve_position, sprite_image) # dissolves the fog of war around that position
			stored_dissolved_positions.append(store_position) # then adds it to the list of dissolved positions
