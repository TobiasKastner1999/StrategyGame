extends TextureRect

var tutorial_state = 0 # the current state of the tutorial

var tracked_variable_one = 2 # the resource type currently tracked by the first slot
var tracked_variable_one_max = 0 # the required value of the first tracked resource type
var tracked_variable_two = 2 # the resource type currently tracked by the second slot
var tracked_variable_two_max = 0 # the required value of the second tracked resource type

# called on each physics frame
func _physics_process(delta):
	if $TutorialPanel.visible:
		updateVariables() # if the panel is visible, updates the tracked resource variables
		checkTutorialAdvancement() # checks if the tutorial should be advanced

# updates the tracked resource variables
func updateVariables():
	if tracked_variable_one != 2:
		# if the first variable is tracking a resource, updates it with the correct value
		$TutorialPanel/ImageTooltipOne.text = str(Global.getResource(Global.player_faction, tracked_variable_one)) + "/" + str(tracked_variable_one_max)
	
	if tracked_variable_two != 2:
		# if hte second variable is tracking a resource, updates it with the correct value
		$TutorialPanel/ImageTooltipTwo.text = str(Global.getResource(Global.player_faction, tracked_variable_two)) + "/" + str(tracked_variable_two_max)

# opens the tutorial panel
func openTutorial():
	checkTutorialAdvancement() # checks if the tutorial state should be advanced
	
	# generates the contents based on the state
	match tutorial_state:
		0:
			# first state: use workers to gather resources
			tracked_variable_one = 0 # tracks the primary resource
			tracked_variable_one_max = Global.unit_dict["worker_robot"]["resource_cost"] # fetches the worker's construction cost
			# loads the correct primary resource icon based on the player's faction
			match Global.player_faction:
				0:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/Models/Map/Scrap.png")
				1:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/zenecium.png")
			$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_start")
		
		1:
			# second state: train additional worker
			$TutorialPanel/ImageTooltipOne.text = "0/1"
			$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/CursorBuilding.png")
			$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_workers")
		
		2:
			# third state: acquire additional resources (to construct forge)
			tracked_variable_one = 0 # tracks the primary resource
			tracked_variable_one_max = Global.getConstructionCost(2) # fetches the forge's construction cost
			# displays the correct primary resource icon based on the player's faction
			match Global.player_faction:
				0:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/Models/Map/Scrap.png")
				1:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/zenecium.png")
			$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_resources")
		
		3:
			# fourth state: construct a forge
			$TutorialPanel/ImageTooltipOne.text = "0/1"
			# displays the correct forge icon based on the player's faction
			match Global.player_faction:
				0:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/OL_Forge_UI.png")
				1:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/NL_Forge_UI.png")
			$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_forge")
		
		4:
			# fifth state: acquire additional resources (to build a barracks & train a combat unit)
			tracked_variable_one = 0 # tracks the primary resource
			tracked_variable_one_max = Global.getConstructionCost(1) # fetches the barracks' construction cost
			# displays the correct primary resource icon based on the player's faction
			match Global.player_faction:
				0:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/Models/Map/Scrap.png")
				1:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/zenecium.png")
			tracked_variable_two = 1 # tracks the secondary resource
			# fetches the correct combat unit training cost based on the player's faction
			match Global.player_faction:
				0:
					tracked_variable_two_max = Global.unit_dict["2"]["resource_cost"]
				1:
					tracked_variable_two_max = Global.unit_dict["0"]["resource_cost"]
			$TutorialPanel/TutorialImageTwo.texture = load("res://Assets/UI/Ore Blau UI.png")
			$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_resources")
		
		5:
			# sixth state: construct a barracks
			$TutorialPanel/ImageTooltipOne.text = "0/1"
			# displays the correct barracks icon based on the player's faction
			match Global.player_faction:
				0:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/OL_Kaserne_UI.png")
				1:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/NL_barracks_UI.png")
			tracked_variable_two = 1 # tracks the secondary resource
			# fetches the correct combat unit training cost based on the player's faction
			match Global.player_faction:
				0:
					tracked_variable_two_max = Global.unit_dict["2"]["resource_cost"]
				1:
					tracked_variable_two_max = Global.unit_dict["0"]["resource_cost"]
			$TutorialPanel/TutorialImageTwo.texture = load("res://Assets/UI/Ore Blau UI.png")
			$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_barracks")
		
		6:
			# seventh state: train a combat unit
			$TutorialPanel/ImageTooltipOne.text = "0/1"
			# displays the correct combat unit icon based on the player's faction
			match Global.player_faction:
				0:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/OL_Fighter_UI.png")
				1:
					$TutorialPanel/TutorialImageOne.texture = load("res://Assets/UI/NL_HeavyUnit_UI.png")
			tracked_variable_two = 1 # tracks the secondary resource
			# fetches the correct combat unit training cost based on the player's faction
			match Global.player_faction:
				0:
					tracked_variable_two_max = Global.unit_dict["2"]["resource_cost"]
				1:
					tracked_variable_two_max = Global.unit_dict["0"]["resource_cost"]
			$TutorialPanel/TutorialImageTwo.texture = load("res://Assets/UI/Ore Blau UI.png")
			$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_troops")
		
		7:
			# eigthth state: further tips
			# displays the correct further info tip based on the player's faction
			match Global.player_faction:
				0:
					$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_final_ol")
				1:
					$TutorialPanel/TutorialTooltip.text = Global.getText("@tutorial_text_final_nl")
	
	updateVariables() # updates the resource variable texts
	$TutorialPanel.visible = true

# closes the tutorial panel
func closeTutorial():
	# resets all variables & icons
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

# returns the current tutorial state
func getTutorialState():
	return tutorial_state

# checks if the tutorial state should be advanced
func checkTutorialAdvancement():
	# performs a check based on the current tutorial state
	match tutorial_state:
		0:
			if Global.getResource(Global.player_faction, 0) >= Global.unit_dict["worker_robot"]["resource_cost"]:
				advanceTutorial() # first state: if the player has acquired enough primary resources to train a worker, advance
		1:
			if get_parent().hq.getCurrentWorkers() > 2:
				advanceTutorial() # second state: if the player has trained an additional worker, advance
		2:
			if Global.getResource(Global.player_faction, 0) >= Global.getConstructionCost(2):
				advanceTutorial() # third state: if the player has acquired enough primary resources to construct a forge, advance
		3:
			if Global.getPlayerBuildings("forge") > 0:
				advanceTutorial() # fourth state: if the player has constructed a forge, advance
		4:
			if Global.getResource(Global.player_faction, 0) >= Global.getConstructionCost(1):
				advanceTutorial() # fifth state: if the player has acquired enough primary resources to construct a barracks, advance
		5:
			if Global.getPlayerBuildings("building") > 0:
				advanceTutorial() # sixth state: if the player has constructed a barracks, advance
		6:
			if Global.getUnitCount(Global.player_faction) > 0:
				advanceTutorial() # seventh state: if the player has trained a combat unit, advance

# advances the tutorial state
func advanceTutorial():
	tutorial_state += 1
	closeTutorial() # first resets the tutorial panel
	openTutorial() # then re-generates the panel

# opens the panel when the player's mouse enters the button
func _on_mouse_entered():
	$".".texture = load("res://Assets/UI/questionmark_UI_pressed.png")
	openTutorial()

# closes the panel once the mouse leaves the button
func _on_mouse_exited():
	$".".texture = load("res://Assets/UI/questionmark_UI.png")
	closeTutorial()
