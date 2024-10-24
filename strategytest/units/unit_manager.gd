extends Node3D

signal delete_selection(unit)

func _on_unit_delete(deleted):
	for unit in get_children():
		if unit.current_target == deleted:
			unit.current_target = null
	delete_selection.emit(deleted)
