extends Button

signal change_type(type) # to tell the interface that a production type change has been requested
signal hover_tooltip(type, bol)

var unit_type : int # the unit type this button represents

# sets the button's unit type
func assignType(type):
	unit_type = int(type)
	text = Global.getText(Global.unit_dict[type]["name"]) # also displays the correct name of the unit

func getType():
	return unit_type

# calls to change unit type production when the button is pressed
func _on_pressed():
	change_type.emit(unit_type)

func _on_mouse_entered():
	hover_tooltip.emit(unit_type, true)

func _on_mouse_exited():
	hover_tooltip.emit(unit_type, false)
