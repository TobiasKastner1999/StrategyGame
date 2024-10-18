extends CanvasLayer


@export var target : NodePath
@export var camera_distance := 20

@onready var main_cam := $"../Node3D"
@onready var camera := $SubViewportContainer/SubViewport/Camera3D
func _ready():
	$SubViewportContainer/SubViewport/unit.position = Vector2($"../unit".position.x,$"../unit".position.z )



func _process(delta):
	$SubViewportContainer/SubViewport/unit.position = Vector2($"../unit".position.x,$"../unit".position.z )
	$SubViewportContainer/SubViewport/Sprite2D.position = Vector2(main_cam.position.x, main_cam.position.z)
	pass
