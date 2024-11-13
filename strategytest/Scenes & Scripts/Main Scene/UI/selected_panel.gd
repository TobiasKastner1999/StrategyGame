extends Node

var current_selected # the currently selected node which the interface represents

# sets the panel's properties when it is activated
func activatePanel(selected):
	if current_selected != null:
		unselect() # unselects the currently selected object (if one exists)
	current_selected = selected # saves the selected object
	updateSelectedInterface() # updates the changing interface properties
	for type in Global.unit_dict:
		var button = load("res://Scenes & Scripts/Prefabs/Interface/unit_type_button.tscn").instantiate()
		$ButtonContainer.add_child(button) # sets up a button for each unit type in the data
		button.assignType(type) # assigns the button to the correct unit type
		button.change_type.connect(_on_type_button_pressed)
	self.visible = true
	selected.interface_update.connect(updateSelectedInterface) # connects object for dynymic updates

# unselects a currently selected object
func unselect():
	self.visible = false
	for button in $ButtonContainer.get_children():
		button.queue_free() # clears all existing buttons
	current_selected.interface_update.disconnect(updateSelectedInterface) # disconnects dynamic updates
	current_selected = null

# updates the dynamic interface components
func updateSelectedInterface():
	$SelectedName.text = "[b]" + current_selected.DISPLAY_NAME + "[/b]" # displays the name
	$SelectedHP.text = "HP: " + str(current_selected.hp) + "/" + str(current_selected.MAX_HP) # displays the object's current hp out of its maximum hp
	if current_selected.spawn_active:
		$SelectedStatus.text = "Status: Active" # displays the object's active status
	else:
		$SelectedStatus.text = "Status: Inactive" # displays the object's inactive status
	$SelectedType.text = "Production Type: " + Global.unit_dict[str(current_selected.production_type)]["name"] # displayers the current unit production type

# calls to toggle the selected object's status when the button is pressed
func _on_button_toggle_pressed():
	current_selected.toggleStatus()
	updateSelectedInterface() # also updates the dynamic interface

# calls to update the building's production type when one of the buttons is pressed
func _on_type_button_pressed(type):
	current_selected.setProductionType(type)
	updateSelectedInterface() # also updates the dynamic interface
