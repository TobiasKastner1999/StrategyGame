extends Node

var current_selected

func activatePanel(selected):
	current_selected = selected
	$SelectedName.text = "[b]" + selected.DISPLAY_NAME + "[/b]"
	$SelectedHP.text = "HP: " + str(selected.hp) + "/" + str(selected.MAX_HP)
	$SelectedStatus.text = "Status: " + str(selected.spawn_active)
	$SelectedType.text = "Type: " + "[...]"
	self.visible = true

func _on_button_toggle_pressed():
	current_selected.toggleStatus()
