extends Node3D

signal building_menu(building) # to activate the interface when the forge is clicked
signal interface_update() # to update the forge's interface display
signal destroyed(forge)

const DISPLAY_NAME = "@name_building_forge" # the forge's displayed name
const TARGET_TYPE = "forge" # the forge's combat type
const RESEARCH_DURATION = 30.0 # how long does it take for the forge to research an upgrade?

var detection_range = 15.0
var researching = false # is the forge currently researching an upgrade?
var faction : int # the faction the forge belongs to
var nearby_observers = [] # a list of enemy units near the forge

@onready var greystate = preload("res://Assets/Materials/material_grey_out.tres")
@onready var hp = Balance.housing_hp # the forge's current hit points, initially set to the maximum hit points

# initially sets up the forge's health bar
func _ready():
	$HealthbarContainer/HealthBar.max_value = Balance.housing_hp # adjusts the health bar display to this unit's maximum hp
	$HealthbarContainer/HealthBar.value = hp

# called on every physics frame
func _physics_process(delta):
	$ProgressbarContainer/ProgressBar.value = $ResearchTimer.time_left
	Global.healthbar_rotation($HealthBarSprite)
	Global.healthbar_rotation($ProgressSprite)

# causes the forge to take a given amount of damage
func takeDamage(damage, _attacker):
	hp -= damage # subtracts the damage taken from the current hp
	$HealthBarSprite.visible = true
	$HealthbarContainer/HealthBar.value = hp # updates the health bar display
	Sound.under_Attack()
	if hp <= 0: # removes the forge if it's remaining hp is 0 or less
		if researching:
			$ResearchTimer.stop()
			Global.setResearchQueue(faction, false)
		Sound.play_sound("res://Sounds/DestroyBuildingSound.mp3", $".")
		await get_tree().create_timer(0.5).timeout
		if faction == Global.player_faction:
			Global.removeKnownTarget(self)
			Global.updateResourceCapacity(faction, -Balance.housing_resource_cap_a, -Balance.housing_resource_cap_b)
			Global.updateBuildingCount(false)
		destroyed.emit(self)
		queue_free() # then deletes the forge
	interface_update.emit() # calls to update the interface with the new health value

# accesses the forge's interface function
func accessStructure():
	building_menu.emit(self)

# returns the forge's current HP
func getHP():
	return hp

# returns the forge's maximum HP
func getMaxHP():
	return Balance.housing_hp

# returns the forge's display name id
func getDisplayName():
	return DISPLAY_NAME

# returns the forge's status
func getInspectInfo(info):
	match info:
		"status":
			if researching:
				return "research"
			else:
				return "inactive"
	return ""

# returns the forge's current research activity state
func inResearch():
	return researching

# starts the forge's research
func startResearch():
	researching = true
	Global.setResearchQueue(faction, true) # queues the research globally to prevent other allied forges from queueing it as well
	$ResearchTimer.start(RESEARCH_DURATION)
	$ProgressbarContainer/ProgressBar.max_value = RESEARCH_DURATION
	$ProgressbarContainer/ProgressBar.value = RESEARCH_DURATION
	$ProgressSprite.visible = true

# aborts the forge's current research
func abortAction():
	researching = false
	Global.setResearchQueue(faction, false)
	$ResearchTimer.stop()
	$ProgressSprite.visible = false
	Global.updateResource(faction, 1, int(ceil(float(Global.getUpgradeCost()) / 2))) # refunds half of the research cost, rounded up
	interface_update.emit()

# sets the forge's faction to a given value
func setFaction(f : int):
	faction = f # sets the faction
	Global.updateResourceCapacity(faction, Balance.housing_resource_cap_a, Balance.housing_resource_cap_b)
	if faction == 0: # when faction is 0
		$OLHousingBody.visible = true # outlaw asset becomes visible
		$OLHousingColl.disabled = false
	elif faction == 1: # when faction is 1
		$NLHousingBody.visible = true # new lights asset becomse visible 
		$ForgeColl.disabled = false

# returns the forge's current faction
func getFaction():
	return faction

# returns the target type (forge)
func getType():
	return TARGET_TYPE

# returns the physical size of the forge
func getSize():
	return ($HousingBody.mesh.size.x / 2)

# removes a given unit from the list of the forge's observers
func clearUnitReferences(unit):
	fowExit(unit)

# called when the forge comes into view of a player-controlled unit
func fowEnter(node):
	if node.getFaction() != faction:
		nearby_observers.append(node)

		fowReveal(true) # enables the visibility of the forge
		setGreystate(false) # enables the greystate of the forge

# called when the forge is no longer in view of a player-controlled unit
func fowExit(node):
	if nearby_observers.has(node):
		nearby_observers.erase(node)
		if nearby_observers.size() == 0:
			setGreystate(true) # disables the greystate of the forge

# sets the visibility of the forge to a given state
func fowReveal(bol):
	if visible != bol:
		visible = bol

# sets the greystate of the forge
func setGreystate(bol):
	if bol:
		$NLHousingBody.material_overlay = greystate
		$OLHousingBody.material_overlay = greystate
	else:
		$NLHousingBody.material_overlay = null
		$OLHousingBody.material_overlay = null

# applies the research once the timer expires
func _on_research_timer_timeout():
	researching = false
	Global.setResearchQueue(faction, false)
	$ProgressSprite.visible = false
	Balance.upgrade1[faction] = true
	interface_update.emit()

func getIcon():
	if Global.player_faction == 0:
		return load("res://Assets/UI/OL_Forge_UI.png")
	else:
		return load("res://Assets/UI/NL_Forge_UI.png")

# when a body enters the building's detection area
func _on_range_area_body_entered(body):
	if body.is_in_group("FowObject") and faction == Global.player_faction:
		body.fowEnter(self) # triggers the object's fow detection

# when a body exits the building's detection area
func _on_range_area_body_exited(body):
	if body.is_in_group("FowObject") and faction == Global.player_faction:
		body.fowExit(self) # updates the object's fow detection
