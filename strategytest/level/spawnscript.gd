extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	var unit = load("res://units/unit2.tscn").instantiate()
	if $"..".unit_counter <= 300:
		get_parent().add_child(unit)
		$"..".unit_counter += 1
	
