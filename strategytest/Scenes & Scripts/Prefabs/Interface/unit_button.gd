extends Button

signal unit_select(selected)

var unit : Node3D

func setUnit(new_unit):
	unit = new_unit
	text = Global.getText(Global.unit_dict[str(unit.getUnitType())]["name"])

func _on_pressed():
	unit_select.emit(unit)
