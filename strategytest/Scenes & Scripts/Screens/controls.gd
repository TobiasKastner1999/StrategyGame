extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$ControlDescription.text = Global.getText("@name_controls")
	$Continue.text = Global.getText("@interface_text_controls_done")
	if Global.player_faction == 0:
		$Mission.text = Global.getText("@interface_text_mission_description_OL")
	elif Global.player_faction == 1:
		$Mission.text = Global.getText("@interface_text_mission_description_NL")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	get_tree().paused = false # ends the game's freeze state
	$".".queue_free()
