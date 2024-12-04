extends Control

signal quit()
var slider_counter = 6
var language = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	checkMusic()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkFlag()
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



func _on_music_plus_button_pressed():
	slider_counter += 1
	checkMusic()

func _on_music_minus_button_pressed():
	slider_counter -= 1
	checkMusic()

func checkMusic():
	var button_container = $Panel/MusicContainer
	for i in range(button_container.get_child_count()):
		var button = button_container.get_child(i)
		if i > slider_counter:
			button.visible = true
		else:
			button.visible = false

func checkFlag():
	if language < 0:
		language = 0
	if language > 1:
		language = 1
	if language == 0:
		$Panel/LanguageSelection/FlagSlot.texture = load("res://Assets/UI/british flag.png")
	elif language == 1:
		$Panel/LanguageSelection/FlagSlot.texture = load("res://Assets/UI/german flag.png")



func _on_language_left_pressed():
	language -= 1


func _on_language_right_pressed():
	language += 1
