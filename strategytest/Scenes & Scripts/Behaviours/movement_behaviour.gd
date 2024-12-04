extends Node

var run_node : Node3D # the node the behaviour is operating on
var current_delta : float # the current physics time delta

# runs the movement behaviour
func runBehaviour(node, delta):
	run_node = node # stores the operating node
	current_delta = delta # stores the current data
	
	if hasMovementDestination(): # checks if the node has a movement destination
		await(moveToDestination()) # if so, moves the node towards that destination
		isDestinationReached() # then checks if the node is close enough to the destination

# checks if the node has a movement destination
func hasMovementDestination():
	if run_node.getDestination() != null and run_node.getDestination() != run_node.getPosition():
		# if the node has a set destination, and that destination isn't its own position
		return true
	return false

# moves the node towards its destination
func moveToDestination():
	var agent = run_node.getNavigationAgent()
	var destination = run_node.getDestination()
	var speed = run_node.getMovementSpeed()
	
	if agent.target_position != destination:
		agent.target_position = destination
	var dir = agent.get_next_path_position() - run_node.getPosition()
	dir = dir.normalized() # sets and normalizes the direction
	
	var new_velocity = run_node.velocity.lerp(dir * speed, 10 * current_delta) # sets the velocity
	agent.set_velocity(new_velocity) # passses the velocity onto the agent
	
	var safe_velocity = await Signal(agent, "velocity_computed") # waits for the agent to calculate a safe velocity (with avoidance)
	run_node.velocity = safe_velocity
	run_node.move_and_slide() # moves the node based on that new velocity

# check if the node has reached its destination
func isDestinationReached():
	var proximity = setProximityDistance() # determines the right proximity distance
	if run_node.global_position.distance_to(run_node.getDestination()) <= proximity:
		# if the node is withing the proximity towards the destination, stops its movement
		run_node.setDestination(run_node.global_position)
		run_node.velocity = Vector3.ZERO

# determines the right proximity distance
func setProximityDistance():
	if run_node.getActiveTarget() != null:
		return run_node.getAttackRange() # proximity is set to the unit's attack range if the unit is moving towards a combat target
	else:
		return (run_node.getAttackRange() / 2.0) # proximity is set to half the unit's attack range otherwise
