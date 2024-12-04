extends Control

signal quit()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("escape") and $".".visible == true:
		if $Panel.visible == false:
			$Panel.visible = true
			get_tree().paused = true
		else:
			$Panel.visible = false
			get_tree().paused = false


func _on_continue_buttons_pressed():
	$Panel.visible = false


func _on_quit_buttons_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes & Scripts/Screens/start_screen.tscn")
	quit.emit()


func _on_menu_button_pressed():
	if $Panel.visible == false:
		$Panel.visible = true
		get_tree().paused = true
	else:
		$Panel.visible = false
		get_tree().paused = false
