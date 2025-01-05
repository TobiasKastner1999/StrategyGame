extends Panel

var current_type : int

func _physics_process(delta):
	pass

func setType(type):
	current_type = type
	$TooltipHP.text = "[b]HP:[/b] " + str(Global.unit_dict[str(current_type)]["max_hp"])
	$TooltipDamage.text = "[b]DP:[/b] " + str(Global.unit_dict[str(current_type)]["damage_value"])
	$TooltipRange.text = "[b]RA:[/b] " + str(Global.unit_dict[str(current_type)]["attack_range"])
	$TooltipAttackRate.text = "[b]AR:[/b] " + str(Global.unit_dict[str(current_type)]["attack_speed"])
	$TooltipVision.text = "[b]VI:[/b] " + str(Global.unit_dict[str(current_type)]["detection_range"])
	$TooltipSpeed.text = "[b]SP:[/b] " + str(Global.unit_dict[str(current_type)]["speed"])
	$TooltipCost.text = "[b]CO:[/b] " + str(Global.unit_dict[str(current_type)]["resource_cost"])
	$TooltipProduction.text = "[b]PR:[/b] " + str(Global.unit_dict[str(current_type)]["production_speed"])
