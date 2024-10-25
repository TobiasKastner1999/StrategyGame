extends Node3D

const UNIT_COST = 1
const SPAWN_RATE = 5.0
var can_spawn = false

var hp = 4

@onready var unit_storage = $"../Units"

func _ready():
	$SpawnTimer.start(SPAWN_RATE)

func _process(delta):
	if can_spawn and Global.crystals >= UNIT_COST:
		spawnUnit()

func spawnUnit():
	can_spawn = false
	Global.crystals -= UNIT_COST
	$SpawnTimer.start(SPAWN_RATE)
	
	var new_unit = load("res://units/unit.tscn").instantiate()
	unit_storage.add_child(new_unit)
	new_unit.global_position = $SpawnPoint.global_position

func _on_spawn_timer_timeout():
	can_spawn = true
