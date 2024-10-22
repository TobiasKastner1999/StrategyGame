extends Node3D



func _ready():
	pass 

func _process(delta):
	pass

func _physics_process(delta):
	pass

#spawn worker when needed
func _on_button_pressed():
	var worker = load("res://units/worker.tscn").instantiate()
	get_parent().add_child(worker)
	worker.global_position = $SpawnPoint.global_position
