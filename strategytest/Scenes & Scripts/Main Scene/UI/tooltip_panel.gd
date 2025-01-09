extends Panel

var current_type : int # the unit type currently displayed through the panel

# sets up the information panel for a given unit type
func setType(type):
	current_type = type
	
	$TooltipHP.text = "[b]" + Global.getText("@inspect_text_hp") + ":[/b] " + str(Global.unit_dict[str(current_type)]["max_hp"])
	$TooltipDamage.text = "[b]" + Global.getText("@inspect_text_damage") + ":[/b] " + str(Global.unit_dict[str(current_type)]["damage_value"])
	$TooltipRange.text = "[b]" + Global.getText("@inspect_text_range") + ":[/b] " + str(Global.unit_dict[str(current_type)]["attack_range"])
	$TooltipAttackRate.text = "[b]" + Global.getText("@inspect_text_attack") + ":[/b] " + str(Global.unit_dict[str(current_type)]["attack_speed"])
	$TooltipVision.text = "[b]" + Global.getText("@inspect_text_vision") + ":[/b] " + str(Global.unit_dict[str(current_type)]["detection_range"])
	$TooltipSpeed.text = "[b]" + Global.getText("@inspect_text_speed") + ":[/b] " + str(Global.unit_dict[str(current_type)]["speed"])
	$TooltipCost.text = "[b]" + Global.getText("@inspect_text_cost") + ":[/b] " + str(Global.unit_dict[str(current_type)]["resource_cost"])
	$TooltipProduction.text = "[b]" + Global.getText("@inspect_text_production") + ":[/b] " + str(Global.unit_dict[str(current_type)]["production_speed"])
