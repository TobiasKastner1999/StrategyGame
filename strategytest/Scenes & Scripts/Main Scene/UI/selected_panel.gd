extends Node

var current_selected # the currently selected node which the interface represents
var multi_selection = [] # the current multi-selection

func _ready():
	updateTexts() # sets the interface texts to the correct language

# sets the interface texts to the correct language
func updateTexts():
	$ButtonToggle.text = Global.getText("@interface_button_toggle_building")
	$ButtonBack.text = Global.getText("@interface_button_back")
	$ButtonDrop.text = Global.getText("@interface_button_drop")
	$ButtonUpgrade.text = Global.getText("@interface_button_upgrade")
	$ButtonAbort.text = Global.getText("@interface_button_abort_research")

# sets the panel's properties when it is activated
func activatePanel(selected):
	unselect() # unselects the currently selected object (if one exists)
	updateTexts() # updates the interface texts
	current_selected = selected # saves the selected object
	
	setUpSelectedInterface() # sets up the interface objects
	self.visible = true
	selected.interface_update.connect(updateSelectedInterface) # connects object for dynymic updates

# unselects a currently selected object
func unselect():
	if current_selected != null:
		current_selected.interface_update.disconnect(updateSelectedInterface) # disconnects dynamic updates
		current_selected = null
	
	self.visible = false
	
	# removes all temporarily instantiated texts & buttons
	for button in $UnitContainer.get_children():
		button.queue_free()
	for button in $ButtonContainer.get_children():
		button.queue_free()
	for info_text in $InfoContainer.get_children():
		info_text.queue_free()

# clears the stored multi-selection
func clearMultiSelection():
	multi_selection = null

# sets up the interface for a multi-selection
func multiSelection(units):
	multi_selection = units

	unselect()
	updateTexts()
	
	$SelectedName.text = "[b]" + str(units.size()) + " " + Global.getText("@interface_text_selected") + "[/b]" # displays the total number of selected units
	$SelectedHP.visible = false
	$ButtonToggle.visible = false
	$ButtonBack.visible = false
	$ButtonDrop.visible = false
	$ButtonUpgrade.visible = false
	$ButtonAbort.visible = false
	
	# creates a button for each selected unit, allowing the player to inspect that unit by clicking the button
	for unit in units:
		var button = load("res://Scenes & Scripts/Prefabs/Interface/unit_button.tscn").instantiate()
		$UnitContainer.add_child(button)
		button.setUnit(unit)
		button.unit_select.connect(_on_unit_select)
	
	self.visible = true

# sets up the interface objects
func setUpSelectedInterface():
	if current_selected == null:
		return # if no selected object exists, does nothing
	elif current_selected.hp <= 0:
		unselect() # unselects the object if it is dead / destroyed
	else:
		$SelectedName.visible = true
		$SelectedHP.visible = true
		$ButtonDrop.visible = false
		$ButtonUpgrade.visible = false
		$ButtonAbort.visible = false
		
		# runs setup based on the object type
		match current_selected.getType():
			"building":
				# sets up the production type selection
				for type in Global.unit_dict:
					if type != "worker" and Global.unit_dict[type]["faction"] == current_selected.getFaction(): 
						var button = load("res://Scenes & Scripts/Prefabs/Interface/unit_type_button.tscn").instantiate()
						$ButtonContainer.add_child(button) # sets up a button for each unit type in the data
						button.assignType(type) # assigns the button to the correct unit type
						button.change_type.connect(_on_type_button_pressed)
						button.hover_tooltip.connect(_on_type_button_hover)
				
				newInfoText("status") # sets up a text for the building's status
				$ButtonToggle.visible = true
			
			"forge":
				newInfoText("status")
				$ButtonToggle.visible = false
				if current_selected.inResearch():
					$ButtonAbort.visible = true
					$ButtonUpgrade.visible = false
				elif !Balance.upgrade1:
					$ButtonUpgrade.visible = true # displays the upgrade button if the upgrade has not yet been purchased
					$ButtonAbort.visible = false
			
			"hq":
				newInfoText("status") # sets up a text for the HQ's status
				$ButtonToggle.visible = true
			
			"worker":
				newInfoText("status") # sets up a text for the worker's status
				newInfoText("resource") # sets up a text for the worker's carried resource
				$ButtonToggle.visible = false
			
			"combat":
				newInfoText("status") # sets up a text for the unit's status
				$ButtonToggle.visible = false
		
		# enables the back button if there is an active multi-selection
		if multi_selection != null:
			$ButtonBack.visible = true
		else:
			$ButtonBack.visible = false
		
		updateSelectedInterface() # updates dynamic UI elements

# creates a new special info text for a given information
func newInfoText(info):
	var info_text = load("res://Scenes & Scripts/Prefabs/Interface/selected_info_text.tscn").instantiate()
	$InfoContainer.add_child(info_text)
	info_text.setInfo(info)

# updates the dynamic interface components
func updateSelectedInterface():
	$SelectedName.text = "[b]" + Global.getText(current_selected.getDisplayName()) + "[/b]" # displays the name
	$SelectedHP.text = Global.getText("@inspect_text_hp") + ": " + str(current_selected.getHP()) + "/" + str(current_selected.getMaxHP()) # displays the object's current hp out of its maximum hp
	
	# updates each special info text
	for info_text in $InfoContainer.get_children():
		info_text.text = Global.getText("@inspect_text_" + info_text.getInfo()) + ": " + Global.getText("@inspect_text_" + info_text.getInfo() + "_" + current_selected.getInspectInfo(info_text.getInfo()))
	
	# updates additional elements based on object type
	match current_selected.getType():
		"building":
			for button in $ButtonContainer.get_children():
				if button.getType() == current_selected.getProduction():
					button.grab_focus() # focus-outlines the button of the currently selected production type
		"forge":
			if current_selected.inResearch():
				$ButtonAbort.visible = true
				$ButtonUpgrade.visible = false
			elif !Balance.upgrade1:
				$ButtonUpgrade.visible = true # displays the upgrade button if the upgrade has not yet been purchased
				$ButtonAbort.visible = false
			else:
				$ButtonUpgrade.visible = false
				$ButtonAbort.visible = false
		
		"worker":
			if current_selected.getResourceState() == 1:
				$ButtonDrop.visible = true
			else:
				$ButtonDrop.visible = false

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
		$SelectedName.visible = false
		$SelectedHP.visible = false
		$InfoContainer.visible = false
		$TooltipPanel.visible = true
		$TooltipDescription.visible = true
		$TooltipPanel.setType(type)
		$TooltipDescription.text = Global.getText(Global.unit_dict[str(type)]["info_text"])
	
	else:
		if $TooltipPanel.current_type == type:
			$TooltipPanel.visible = false
			$TooltipDescription.visible = false
			$SelectedName.visible = true
			$SelectedHP.visible = true
			$InfoContainer.visible = true

# calls to access a unit from the multi-selection
func _on_unit_select(unit):
	unselect()
	unit.accessUnit()

# calls to return to the multi-selection from an individual unit
func _on_button_back_pressed():
	multiSelection(multi_selection)

# calls for the worker to drop their carried resource if the drop button is pressed
func _on_button_drop_pressed():
	current_selected.clearResource()

# attempts to upgrade the player's combat units if the upgrade button is pressed
func _on_button_upgrade_pressed():
	# only performs the upgrade if the player actually has enough resources as well
	if Global.getResource(Global.player_faction, 1) >= Global.getUpgradeCost() and !current_selected.inResearch():
		Global.updateResource(Global.player_faction, 1, -Global.getUpgradeCost())
		current_selected.startResearch()
		updateSelectedInterface()

func _on_button_abort_pressed():
	current_selected.abortAction()
