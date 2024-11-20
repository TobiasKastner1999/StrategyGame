extends Node3D

signal delete_selection(unit) # to tell camera to remove a deleted unit from the selection
signal new_unit(unit)

# calls to connect a newly attached unit's deletion signal
func connectDeletion(unit):
	unit.deleted.connect(_on_unit_delete)
	if unit.getFaction() == Global.player_faction:
		new_unit.emit(unit)

# called when a unit is deleted
func _on_unit_delete(deleted):
	# checks for each other unit of they have the deleted unit as their current target
	for unit in get_children():
		if unit.current_target == deleted:
			unit.current_target = null # if a unit does, its target is cleared
	delete_selection.emit(deleted) # also instructs the camera to remove the deleted unit from its selection
