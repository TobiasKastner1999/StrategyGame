extends Panel

var current_tooltip : int

func updateTooltip(active, type):
	if active:
		current_tooltip = type
		
		match type:
			1:
				$TextName.text = "[b]" + Global.getText("@name_building_barracks") + "[/b]"
				$TextDescription.text = Global.getText("@inspect_text_description_barracks")
			2:
				$TextName.text = "[b]" + Global.getText("@name_building_forge") + "[/b]"
				$TextDescription.text = Global.getText("@inspect_text_description_forge")
		
		$TextCost.text = "[b]" + Global.getText("@inspect_text_cost") + ":[/b] " + str(Global.getConstructionCost(type))
		visible = true
	
	else:
		if current_tooltip != null and type == current_tooltip:
			visible = false
			for info_text in get_children():
				info_text.text = ""
