extends Node3D



func _ready():
	pass 

func _process(delta):
	pass


#spawns up to 300 units to test the performance of the engine
func _on_timer_timeout():
	var unit = load("res://units/Unit.tscn").instantiate()
	if $"..".unit_counter <= 300:
		get_parent().add_child(unit)
		$"..".unit_counter += 1
	
