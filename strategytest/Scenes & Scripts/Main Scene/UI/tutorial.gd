extends TextureRect

var tutorial_state = 0

var tracked_variable_one = 2
var tracked_variable_one_max = 0
var tracked_variable_two = 2
var tracked_variable_two_max = 0

func _physics_process(delta):
	if $TutorialPanel.visible:
		updateVariables()
		checkTutorialAdvancement()

func updateVariables():
	if tracked_variable_one != 2:
		$TutorialPanel/ImageTooltipOne.text = str(Global.getResource(Global.player_faction, tracked_variable_one)) + "/" + str(tracked_variable_one_max)
	
	if tracked_variable_two != 2:
		$TutorialPanel/ImageTooltipTwo.text = str(Global.getResource(Global.player_faction, tracked_variable_two)) + "/" + str(tracked_variable_two_max)

func openTutorial():
	checkTutorialAdvancement()
	
	match tutorial_state:
		0:
			tracked_variable_one = 0
			tracked_variable_one_max = Global.unit_dict["worker_robot"]["resource_cost"]
			match Global.player_faction:
				0:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/Models/Map/Scrap.png")
				1:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/zenecium.png")
			$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_start")
			pass # gather resources
		1:
			$TutorialPanel/ImageTooltipOne.text = "0/1"
			$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/CursorBuilding.png")
			$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_workers")
			pass # train workers
		2:
			tracked_variable_one = 0
			tracked_variable_one_max = Global.getConstructionCost(2)
			match Global.player_faction:
				0:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/Models/Map/Scrap.png")
				1:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/zenecium.png")
			$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_resources")
			pass # gather more resources
		3:
			$TutorialPanel/ImageTooltipOne.text = "0/1"
			match Global.player_faction:
				0:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/OL_Forge_UI.png")
				1:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/NL_Forge_UI.png")
			$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_forge")
			pass # build forge
		4:
			tracked_variable_one = 0
			tracked_variable_one_max = Global.getConstructionCost(1)
			match Global.player_faction:
				0:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/Models/Map/Scrap.png")
				1:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/zenecium.png")
			tracked_variable_two = 1
			match Global.player_faction:
				0:
					tracked_variable_two_max = Global.unit_dict["2"]["resource_cost"]
				1:
					tracked_variable_two_max = Global.unit_dict["0"]["resource_cost"]
			$TutorialPanel/TutorialImageTwo.texture = load("res://Assets/UI/Ore Blau UI.png")
			$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_resources")
			pass # gather more resources
		5:
			$TutorialPanel/ImageTooltipOne.text = "0/1"
			match Global.player_faction:
				0:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/OL_Kaserne_UI.png")
				1:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/NL_barracks_UI.png")
			tracked_variable_two = 1
			match Global.player_faction:
				0:
					tracked_variable_two_max = Global.unit_dict["2"]["resource_cost"]
				1:
					tracked_variable_two_max = Global.unit_dict["0"]["resource_cost"]
			$TutorialPanel/TutorialImageTwo.texture = load("res://Assets/UI/Ore Blau UI.png")
			$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_barracks")
			pass # build barracks
		6:
			$TutorialPanel/ImageTooltipOne.text = "0/1"
			match Global.player_faction:
				0:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/OL_Fighter_UI.png")
				1:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/NL_HeavyUnit_UI.png")
			tracked_variable_two = 1
			match Global.player_faction:
				0:
					tracked_variable_two_max = Global.unit_dict["2"]["resource_cost"]
				1:
					tracked_variable_two_max = Global.unit_dict["0"]["resource_cost"]
			$TutorialPanel/TutorialImageTwo.texture = load("res://Assets/UI/Ore Blau UI.png")
			$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_troops")
			pass # train units
		7:
			match Global.player_faction:
				0:
					$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_final_ol")
				1:
					$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_final_nl")
			pass # final state
	
	updateVariables()
	$TutorialPanel.visible = true

func closeTutorial():
	$TutorialPanel.visible = false
	$TutorialPanel/TutorialImageOne.texture = null
	$TutorialPanel/TutorialImageTwo.texture = null
	$TutorialPanel/TutorialTooltip.text = ""
	$TutorialPanel/ImageTooltipOne.text = ""
	$TutorialPanel/ImageTooltipTwo.text = ""
	tracked_variable_one = 2
	tracked_variable_one_max = 0
	tracked_variable_two = 2
	tracked_variable_two_max = 0

func getTutorialState():
	return tutorial_state

func checkTutorialAdvancement():
	match tutorial_state:
		0:
			if Global.getResource(Global.player_faction, 0) >= Global.unit_dict["worker_robot"]["resource_cost"]:
				advanceTutorial()
		1:
			if get_parent().hq.getCurrentWorkers() > 2:
				advanceTutorial()
		2:
			if Global.getResource(Global.player_faction, 0) >= Global.getConstructionCost(2):
				advanceTutorial()
		3:
			if Global.getPlayerBuildings("forge") > 0:
				advanceTutorial()
		4:
			if Global.getResource(Global.player_faction, 0) >= Global.getConstructionCost(1):
				advanceTutorial()
		5:
			if Global.getPlayerBuildings("building") > 0:
				advanceTutorial()
		6:
			if Global.getUnitCount(Global.player_faction) > 0:
				advanceTutorial()

func advanceTutorial():
	tutorial_state += 1
	closeTutorial()
	openTutorial()

func _on_mouse_entered():
	$".".texture = load("res://Assets/UI/questionmark_UI_pressed.png")
	openTutorial()

func _on_mouse_exited():
	$".".texture = load("res://Assets/UI/questionmark_UI.png")
	closeTutorial()
