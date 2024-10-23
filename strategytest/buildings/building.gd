extends Node3D

var hp = 4

# test healthbar for building
func _process(delta):
	if hp == 4:
		$TestHealthBar.value = 100
	if hp == 3:
		$TestHealthBar.value = 75
	if hp == 2:
		$TestHealthBar.value = 50
	if hp == 1:
		$TestHealthBar.value = 25
	if hp == 0:
		queue_free()

#when enemy enters it starts a timer that deals damage per tick
func _on_timer_timeout():
	hp -= 1

func _on_area_3d_body_entered(body):
	if body.is_in_group("Team2"):
		$Timer.start()

func _on_area_3d_body_exited(body):
	if body.is_in_group("Team2"):
		$Timer.stop()
