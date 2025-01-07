extends Button

signal unit_select(selected) # to inform the system that this unit has been selected

var unit : Node3D # the unit this button represents

# assigns a represented unit to this button
func setUnit(new_unit):
	unit = new_unit
	text = Global.getText(Global.unit_dict[str(unit.getUnitType())]["name"]) # sets the button's text to the unit's name

# selects the represented unit when the player presses the button
func _on_pressed():
	unit_select.emit(unit)
