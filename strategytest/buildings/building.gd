extends Node3D


var HP = 4


func _ready():
	pass 


#test healthbar for building
func _process(delta):
	if HP == 4:
		$TestHealthBar.value = 100
	if HP == 3:
		$TestHealthBar.value = 75
	if HP == 2:
		$TestHealthBar.value = 50
	if HP == 1:
		$TestHealthBar.value = 25
	if HP == 0:
		queue_free()

#when enemy enters it starts a timer that deals damage per tick
func _on_timer_timeout():
	print("aua")
	HP -= 1


func _on_area_3d_body_entered(body):
	if body.is_in_group("Team2"):
		$Timer.start()


func _on_area_3d_body_exited(body):
	if body.is_in_group("Team2"):
		$Timer.stop()
