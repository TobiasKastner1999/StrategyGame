extends Node3D

var nl_housing_mesh = null
var nl_wall_mesh = null
var nl_barracks_mesh = null
var ol_barracks_mesh = null
# Called when the node enters the scene tree for the first time.
func _ready():
	nl_housing_mesh = $NLHousingBody.mesh
	nl_wall_mesh = $WallBody.mesh
	nl_barracks_mesh = $NLBarracks.mesh
	ol_barracks_mesh = $OLBarracks.mesh

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
