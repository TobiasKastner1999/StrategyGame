extends Panel

var current_tooltip : int # the current structure represented by the tooltip

# updates the tooltip
func updateTooltip(active, type):
	# if the tooltip is being activated
	if active:
		current_tooltip = type # saves the represented structure
		
		# sets the correct text based on the structure type
		match type:
			1:
				$TextName.text = "[b]" + Global.getText("@name_building_barracks") + "[/b]"
				$TextDescription.text = Global.getText("@inspect_text_description_barracks")
			2:
				$TextName.text = "[b]" + Global.getText("@name_building_forge") + "[/b]"
				$TextDescription.text = Global.getText("@inspect_text_description_forge")
		
		$TextCost.text = "[b]" + Global.getText("@inspect_text_cost") + ":[/b] " + str(Global.getConstructionCost(type))
		visible = true
	
	# if the tooltip is being deactivated
	else:
		if current_tooltip != null and type == current_tooltip:
			visible = false # hides the tooltip if it was representing the called object
			for info_text in get_children():
				info_text.text = "" # resets all the texts as well
