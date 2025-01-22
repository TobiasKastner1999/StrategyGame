extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func shoot():
	$GPUParticles3D.emitting = true
	$GPUParticles3D2.emitting = true
	await  get_tree().create_timer(0.1).timeout
	$GPUParticles3D.emitting = false
	$GPUParticles3D2.emitting = false
