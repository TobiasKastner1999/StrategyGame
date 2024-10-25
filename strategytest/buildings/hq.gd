extends Node3D

# spawn worker when needed
func _on_button_pressed():
	var worker = load("res://units/worker.tscn").instantiate()
	$Workers.add_child(worker)
	worker.global_position = $SpawnPoint.global_position
	worker.hq = self
