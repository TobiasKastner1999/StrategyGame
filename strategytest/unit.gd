extends RigidBody2D
var target = null
var marked = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target != null:
		var velocity = target * 100
		#$".".global_position = target
		#$CollisionShape2D.global_position = target
	if marked == true:
		$Sprite2D.modulate = Color.WEB_MAROON
	elif marked != true:
		$Sprite2D.modulate = Color.WHITE
