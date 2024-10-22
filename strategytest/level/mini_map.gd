extends CanvasLayer


@onready var unit_sprite = $MiniMapContainer/MiniMapViewPort/UnitSprite
@onready var main_cam := $"../Camera"
@onready var unit = $"../Unit"
@onready var cam_sprite = $MiniMapContainer/MiniMapViewPort/CamSprite



#sets the position of the unit on the minimap
func _ready():
	unit_sprite.position = Vector2(unit.position.x,unit.position.z )


#when unit/camera move the minimap sprites follow
func _process(delta):
	if unit != null:
		unit_sprite.position = Vector2(unit.position.x,unit.position.z )
		cam_sprite.position = Vector2(main_cam.position.x, main_cam.position.z)

