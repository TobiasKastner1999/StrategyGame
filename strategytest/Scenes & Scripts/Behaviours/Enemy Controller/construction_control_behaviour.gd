extends Node

var controller : Node3D
var controlled_faction : int

func runBehaviour():
	if !initialConstructionStatus():
		continueInitialConstruction()
	if atResourceLimit():
		attemptConstruction("forge")
	attemptConstruction("wall")
	attemptConstruction("barracks")
	
func initialConstructionStatus():
	return false

func continueInitialConstruction():
	attemptConstruction("forge")
	attemptConstruction("barracks")

func atResourceLimit():
	return true

func attemptConstruction(type):
	match type:
		"forge":
			pass
		"barracks":
			pass
		"wall":
			pass

func setControlled(node):
	controller = node
	controlled_faction = controller.getFaction()
