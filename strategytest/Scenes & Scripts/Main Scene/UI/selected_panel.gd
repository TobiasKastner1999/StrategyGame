extends Node

var current_selected # the currently selected node which the interface represents

# sets the panel's properties when it is activated
func activatePanel(selected):
	current_selected = selected # saves the selected object
	$SelectedName.text = "[b]" + selected.DISPLAY_NAME + "[/b]" # displays the name
	$SelectedHP.text = "HP: " + str(selected.hp) + "/" + str(selected.MAX_HP) # displays the object's current hp out of its maximum hp
	$SelectedStatus.text = "Status: " + str(selected.spawn_active) # displays the object's status
	$SelectedType.text = "Type: " + "[...]"
	self.visible = true

# calls to toggle the selected object's status when the button is pressed
func _on_button_toggle_pressed():
	current_selected.toggleStatus()
