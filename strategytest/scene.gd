extends Node2D

var dragging = false
var selection = []
var drag_start = Vector2.ZERO
var selection_rect = RectangleShape2D.new()



func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:

			if selection.size() == 0:
				dragging = true
				drag_start = event.position
			else:
				for item in selection:
					item.collider.marked = false
					item.collider.target = get_global_mouse_position()
				selection = []

		elif dragging == true:
			dragging = false
			queue_redraw()
			var drag_end = event.position
			selection_rect.size = (drag_end - drag_start).abs()
			
			var space = get_world_2d().direct_space_state
			var query = PhysicsShapeQueryParameters2D.new()
			query.set_shape(selection_rect)
			query.transform = Transform2D (0, (drag_end + drag_start) / 2)
			selection = space.intersect_shape(query)
			#print(selection)

			for item in selection:
				item.collider.marked = true
				print(item)
			
	if event is InputEventMouseMotion and dragging == true:
		
		queue_redraw()

func _draw():
	if dragging == true:
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start),Color.ORANGE,true)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_right"):
		print(dragging)
