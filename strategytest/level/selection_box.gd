
extends Control


var isVisible = false
var mousePosition = Vector2()
var startSelectionPosition = Vector2()
var selectionBoxColor = Color(0, 1, 0)
var selectionBoxLineWidth = 1


#draws the selectionbox when dragged with mouse
func _draw():

	if isVisible and startSelectionPosition != mousePosition:
		draw_line(startSelectionPosition, Vector2(mousePosition.x, startSelectionPosition.y,), selectionBoxColor, selectionBoxLineWidth)
		draw_line(startSelectionPosition, Vector2(startSelectionPosition.x, mousePosition.y), selectionBoxColor, selectionBoxLineWidth)
		draw_line(mousePosition, Vector2(mousePosition.x, startSelectionPosition.y), selectionBoxColor, selectionBoxLineWidth)
		draw_line(mousePosition, Vector2(startSelectionPosition.x, mousePosition.y), selectionBoxColor, selectionBoxLineWidth)

	

func _process(_delta):
	queue_redraw() 
