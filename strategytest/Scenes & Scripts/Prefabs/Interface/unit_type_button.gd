extends TextureButton

signal change_type(type) # to tell the interface that a production type change has been requested
signal hover_tooltip(type, bol) # to tell the interface that the player is hovering over a production type

var unit_type : int # the unit type this button represents

func _ready():
	Global.unit_dict["0"]["texture_normal"] = load("res://Assets/UI/OL_Fighter_UI.png") # NL light png
	Global.unit_dict["0"]["texture_pressed"] = load("res://Assets/UI/OL_Fighter_UI_pressed.png")
	Global.unit_dict["1"]["texture_normal"] = load("res://Assets/UI/OL_Fighter_UI.png") # NL heavy png
	Global.unit_dict["1"]["texture_pressed"] = load("res://Assets/UI/OL_Fighter_UI_pressed.png")
	Global.unit_dict["2"]["texture_normal"] = load("res://Assets/UI/OL_Fighter_UI.png") # OL light png
	Global.unit_dict["2"]["texture_pressed"] = load("res://Assets/UI/OL_Fighter_UI_pressed.png")
	Global.unit_dict["3"]["texture_normal"] = load("res://Assets/UI/OL_GunVehicle_UI.png") # OL heavy png
	Global.unit_dict["3"]["texture_pressed"] = load("res://Assets/UI/OL_Fighter_UI_pressed.png")




# sets the button's unit type
func assignType(type):
	unit_type = int(type)
	#text = Global.getText(Global.unit_dict[type]["name"]) # also displays the correct name of the unit
	texture_normal = Global.unit_dict[type]["texture_normal"]
	texture_pressed = Global.unit_dict[type]["texture_pressed"]

# returns the unit type represented by this button
func getType():
	return unit_type

# calls to change unit type production when the button is pressed
func _on_pressed():
	Sound.play_sound_all("res://Sounds/Button Sound Variante 1.mp3",$"." )
	change_type.emit(unit_type)

# calls to display the tooltip panel when the button is hovered
func _on_mouse_entered():
	hover_tooltip.emit(unit_type, true)

# calls to hide the tooltip panel if the button is no longer hovered
func _on_mouse_exited():
	hover_tooltip.emit(unit_type, false)
