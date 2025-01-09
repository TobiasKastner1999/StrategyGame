extends Panel

var current_type : int # the unit type currently displayed through the panel

# sets up the information panel for a given unit type
func setType(type):
	current_type = type
	
	$TooltipHP.text = "[b]HP:[/b] " + str(Global.unit_dict[str(current_type)]["max_hp"])
	$TooltipDamage.text = "[b]Dmg:[/b] " + str(Global.unit_dict[str(current_type)]["damage_value"])
	$TooltipRange.text = "[b]Range:[/b] " + str(Global.unit_dict[str(current_type)]["attack_range"])
	$TooltipAttackRate.text = "[b]AtSp:[/b] " + str(Global.unit_dict[str(current_type)]["attack_speed"])
	$TooltipVision.text = "[b]Vis:[/b] " + str(Global.unit_dict[str(current_type)]["detection_range"])
	$TooltipSpeed.text = "[b]Sp:[/b] " + str(Global.unit_dict[str(current_type)]["speed"])
	$TooltipCost.text = "[b]Cost:[/b] " + str(Global.unit_dict[str(current_type)]["resource_cost"])
	$TooltipProduction.text = "[b]PrTi:[/b] " + str(Global.unit_dict[str(current_type)]["production_speed"])
