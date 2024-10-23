extends Node3D

# spawn worker when needed
func _on_button_pressed():
	var worker = load("res://units/worker.tscn").instantiate()
	$Workers.add_child(worker)
	worker.global_position = $SpawnPoint.global_position
	worker.deposit_crystal.connect(_on_crystal_deposit)
	worker.hq = self

func _on_crystal_deposit():
	$"..".crystals += 1
