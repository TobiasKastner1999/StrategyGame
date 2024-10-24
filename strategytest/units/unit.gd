extends CharacterBody3D

signal deleted(unit)

const MAX_HP = 10
const DAMAGE_VALUE = 1
const ATTACK_RANGE = 2
const ATTACK_SPEED = 2.0
var can_attack = true
var nearby_enemies = []
var current_target : CharacterBody3D
var priority_movement = false

const SPEED = 12
var SR 
var path = []
var path_ind = 0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var faction : int

@onready var hp = MAX_HP
@onready var navi : NavigationAgent3D = $NavAgent
@onready var go_to = global_position

func _ready():
	if faction == 1:
		$UnitBody/EnemyIdentifier.visible = true
	$HealthbarContainer/HealthBar.max_value = MAX_HP
	$HealthbarContainer/HealthBar.value = hp

func _physics_process(delta):
	# gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if priority_movement == false:
		if current_target != null:
			if global_position.distance_to(current_target.global_position) <= ATTACK_RANGE:
				if can_attack:
					attackTarget()
			else:
				go_to = current_target.global_position
	
		else:
			if nearby_enemies.size() > 0:
				var min_distance
				var intend_target
				for enemy in nearby_enemies:
					var distance = global_position.distance_to(enemy.global_position)
					if (min_distance == null) or (distance < min_distance):
						min_distance = distance
						intend_target = enemy
				if min_distance <= ATTACK_RANGE:
					current_target = intend_target
					if can_attack:
						attackTarget()
				else:
					go_to = intend_target.global_position
	
	# attack priority target
	
	# sets the movement of the unit and stops when close to goal
	if go_to != global_position:
		navi.target_position = go_to
		var dir = navi.get_next_path_position() - global_position
		dir = dir.normalized()
		velocity = velocity.lerp(dir *SPEED, 10 * delta)
		if position.distance_to(go_to) < 1:
			go_to = global_position
			velocity = Vector3.ZERO
			priority_movement = false
		move_and_slide()

# receives the path from NavAgent
func move_to(target_pos):
	path = navi.get_simple_path(global_transform.origin, target_pos)
	path_ind = 0

func attackTarget():
	go_to = global_position
	current_target.takeDamage(DAMAGE_VALUE)
	can_attack = false
	$AttackCooldown.start(ATTACK_SPEED)

func takeDamage(damage):
	hp -= damage
	$HealthbarContainer/HealthBar.value = hp
	if hp == 0:
		deleted.emit(self)
		queue_free()

# changes the color of the unit when selected or deselected
func select():
	$UnitBody.material_override = load("res://units/new_standard_material_3d_gelb.tres")

func deselect():
	$UnitBody.material_override = load("res://units/new_standard_material_3d_weiß.tres")

func setFaction(f : int):
	faction = f

func getFaction():
	return faction

# sets the position the NavAgent will move to
func setTargetPosition(target):
	priority_movement = true
	go_to = target

# combat funtions when enemy unit enters range the timer starts and ticks damage to the unit 
# when HP is 0 the unit is deleted
func _on_area_3d_body_entered(body):
	if body.is_in_group("CombatTarget") and body.getFaction() != faction:
		nearby_enemies.append(body)

func _on_area_3d_body_exited(body):
	if nearby_enemies.has(body):
		nearby_enemies.erase(body)

func _on_timer_timeout():
	can_attack = true
