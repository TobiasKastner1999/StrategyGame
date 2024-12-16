extends Node3D

signal delete_selection(unit) # to tell camera to remove a deleted unit from the selection
signal new_unit(unit) # to notify to system about new unit spawns

# calls to connect a newly attached unit's deletion signal
func connectDeletion(unit):
	unit.deleted.connect(_on_unit_delete)
	if unit.getFaction() == Global.player_faction:
		new_unit.emit(unit) # tells the system that a new unit has been spawned

# called when a unit is deleted
func _on_unit_delete(deleted):
	# checks for each other unit of they have the deleted unit as their current target
	for unit in get_children():
		unit.checkUnitRemoval(deleted) # has each unit remove potential references to the deleted unit
	delete_selection.emit(deleted) # also instructs the camera to remove the deleted unit from its selection
