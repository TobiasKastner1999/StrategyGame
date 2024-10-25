extends CanvasLayer

@onready var unit_sprite = $MiniMapContainer/MiniMapViewPort/UnitSprite
@onready var main_cam := $"../Camera"
@onready var cam_sprite = $MiniMapContainer/MiniMapViewPort/CamSprite

# when unit/camera move the minimap sprites follow
func _process(delta):
	cam_sprite.position = Vector2(main_cam.position.x, main_cam.position.z)

