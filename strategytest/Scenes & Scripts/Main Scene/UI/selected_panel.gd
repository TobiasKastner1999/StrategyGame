extends Node

var current_selected # the currently selected node which the interface represents
var multi_selection = []

func _ready():
	updateTexts() # sets the interface texts to the correct language

# sets the interface texts to the correct language
func updateTexts():
	$ButtonToggle.text = Global.getText("@interface_button_toggle_building")

# sets the panel's properties when it is activated
func activatePanel(selected):
	updateTexts()
	
	unselect() # unselects the currently selected object (if one exists)
	current_selected = selected # saves the selected object
	
	setUpSelectedInterface() # sets up the interface objects
	self.visible = true
	selected.interface_update.connect(updateSelectedInterface) # connects object for dynymic updates

# unselects a currently selected object
func unselect():
	self.visible = false
	for button in $UnitContainer.get_children():
		button.queue_free()
	for button in $ButtonContainer.get_children():
		button.queue_free() # clears all existing buttons
	for info_text in $InfoContainer.get_children():
		info_text.queue_free()
	if current_selected != null:
		current_selected.interface_update.disconnect(updateSelectedInterface) # disconnects dynamic updates
		current_selected = null

func multiSelection(units):
	unselect()
	updateTexts()
	
	$SelectedName.text = "[b]" + str(units.size()) + " " + Global.getText("@interface_text_selected") + "[/b]"
	$SelectedHP.visible = false
	$ButtonToggle.visible = false
	
	for unit in units:
		var button = load("res://Scenes & Scripts/Prefabs/Interface/unit_button.tscn").instantiate()
		$UnitContainer.add_child(button)
		button.setUnit(unit)
		button.unit_select.connect(_on_unit_select)
	
	self.visible = true

# sets up the interface objects
func setUpSelectedInterface():
	$SelectedHP.visible = true
	if current_selected == null:
		return # if no selected object exists, does nothing
	elif current_selected.hp <= 0:
		unselect() # unselects the object if it is dead / destroyed
	else:
		# runs setup based on the object type
		match current_selected.getType():
			"building":
				# sets up the production type selection
				for type in Global.unit_dict:
					if type != "worker": 
						var button = load("res://Scenes & Scripts/Prefabs/Interface/unit_type_button.tscn").instantiate()
						$ButtonContainer.add_child(button) # sets up a button for each unit type in the data
						button.assignType(type) # assigns the button to the correct unit type
						button.change_type.connect(_on_type_button_pressed)
						button.hover_tooltip.connect(_on_type_button_hover)
				
				newInfoText("status")
				$ButtonToggle.visible = true
			
			"hq":
				$ButtonToggle.visible = false
			
			"worker":
				newInfoText("status")
				newInfoText("resource")
				$ButtonToggle.visible = false
			
			"combat":
				newInfoText("status")
				$ButtonToggle.visible = false
		
		updateSelectedInterface() # updates dynamic UI elements

func newInfoText(info):
	var info_text = load("res://Scenes & Scripts/Prefabs/Interface/selected_info_text.tscn").instantiate()
	$InfoContainer.add_child(info_text)
	info_text.setInfo(info)

# updates the dynamic interface components
func updateSelectedInterface():
	$SelectedName.text = "[b]" + Global.getText(current_selected.DISPLAY_NAME) + "[/b]" # displays the name
	$SelectedHP.text = Global.getText("@inspect_text_hp") + ": " + str(current_selected.getHP()) + "/" + str(current_selected.getMaxHP()) # displays the object's current hp out of its maximum hp
	
	for info_text in $InfoContainer.get_children():
		info_text.text = Global.getText("@inspect_text_" + info_text.getInfo()) + ": " + Global.getText("@inspect_text_" + info_text.getInfo() + "_" + current_selected.getInspectInfo(info_text.getInfo()))
	
	# updates additional elements based on object type
	match current_selected.getType():
		"building":
			for button in $ButtonContainer.get_children():
				if button.getType() == current_selected.getProduction():
					button.grab_focus() # focus-outlines the button of the currently selected production type

# calls to toggle the selected object's status when the button is pressed
func _on_button_toggle_pressed():
	current_selected.toggleStatus()
	updateSelectedInterface() # also updates the dynamic interface

# calls to update the building's production type when one of the buttons is pressed
func _on_type_button_pressed(type):
	current_selected.setProductionType(type)
	updateSelectedInterface() # also updates the dynamic interface

# toggles the tooltip panel on hover over a selection type
func _on_type_button_hover(type, bol):
	if bol:
		$TooltipPanel.visible = true
		$TooltipPanel.setType(type)
	
	else:
		if $TooltipPanel.current_type == type:
			$TooltipPanel.visible = false

func _on_unit_select(unit):
	unselect()
	unit.accessUnit()
