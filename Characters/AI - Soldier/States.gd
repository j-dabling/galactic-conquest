extends Node
#################################### thing #####################################

################################## Variables ###################################
onready var root = get_owner()
#var soldier = get_tree().get_node("Soldier")
onready var player = get_node("../../Player")
onready var head = get_node("../Head")
# Working with ints is easier than working with strings.
enum {idle, advance, combat, retreat, cover}
#     0     1        2       3        4
var state_status = {idle:0.0, advance:0.0, combat:0.0, retreat:0.0, cover:0.0}
export var state_weights = [0.1, 0.1, 0.1, 10, 0.1]
export var active_state : int = idle

# Keeps track of all notable bodies in proximity.
var proximity_dict = {}
var sight_list = []

var objective_pos = Vector3.ZERO
################################ End Variables #################################

#################################### Utils #####################################
func get_highest_state():
	var highest = 0
	for s in state_status:
		if state_status[s] > state_status[highest]:
			highest = s
	return highest


func sum_list(list):
	var sum = 0
	for i in list:
		sum += i
	return sum


func look_to(pos):
	var direction = player.transform.origin.direction_to(root.transform.origin)
	root.rotation.y = direction.x
	head.rotation.x = -1 * direction.y
	return direction


func _on_Proximity_body_entered(body):
	if body.is_in_group("Allies"):
		proximity_dict[body] = abs(5 - abs(root.translation.distance_to(body.translation)))

func _on_Proximity_body_exited(body):
	if body in proximity_dict:
		proximity_dict.erase(body)


func _on_FOV_body_entered(body):
	if body.is_in_group("Allies"):
		sight_list.append(body)

func _on_FOV_body_exited(body):
	if body in sight_list:
		sight_list.erase(body)
################################## End Utils ###################################

#################################### Logic #####################################
func evaluate_proximity():
	for foo in proximity_dict:
		proximity_dict[foo] = abs(root.translation.distance_to(foo.translation) - state_weights[retreat])
	state_status[retreat] = sum_list(proximity_dict.values()) * state_weights[retreat]


func evaluate_objective():
	if Input.is_action_just_pressed("primary_fire"):
		state_status[advance] += 1
	elif Input.is_action_just_pressed("secondary_fire") and state_status[advance] > 0:
		state_status[advance] -= 1
	# On signal recieving objective, 
	#	if objective is at current location:
	#		increase state_status[idle] accordingly.
	#	if objective is not reached:
	#		increase state_status[advance] according to distance to point.
	#	if cannot proceed to objective, send signal "cannot comply".


func evaluate_vision():
	state_status[combat] = len(sight_list)
	for dude in sight_list:
		state_status[combat] += abs(root.translation.distance_to(dude.translation) - state_weights[combat])


func _process(delta):
	evaluate_proximity()
	evaluate_objective()
	evaluate_vision()
	
	active_state = get_highest_state()
	print(active_state)
	match active_state:
		idle:
			pass
		advance:
			advance()
		combat:
			pass
		retreat:
			retreat()
		cover:
			pass

################################## End Logic ###################################

################################ Advance State #################################
# Creates a Vector2 from current position to objective position.
# Vector2 will be passed to move() in Soldier.gd
func advance():
	if not has_reached(objective_pos):
#		var direction = root.transform.origin.direction_to(Vector3(0,0,0))#(root.transform.origin - Vector3(0,0,0)).normalized()#(objective_pos - root.transform.origin).normalized()
#		var direction =  -1 * root.transform.origin.direction_to(player.transform.origin)
#		root.move_axis = Vector2(direction.z, direction.x)
#		root.move_axis = Vector2(-1,1)
#		root.rotation.y = direction.x
#		print("direction: %s" % direction
		var dir = look_to(objective_pos)
		root.move_axis = Vector2(dir.z, dir.x)
#	print(root.move_axis)
#	print("objective_pos: %s" % objective_pos)

# Checks to see if position is "close enough" to objective to consider it reached.
func has_reached(pos):
	if root.translation.distance_to(pos) <= 5:
		state_status[advance] -= 1
		root.move_axis = Vector2(0,0)
		return true
	else:
		return false
############################## End Advance State ###############################

################################ Retreat State #################################
func retreat():
#	var direction = root.transform.origin.direction_to(get_closest_hazard().transform.origin)
#	root.move_axis = Vector2(direction.x, direction.z)
	look_to(objective_pos)

func get_closest_hazard():
	var closest_hazard = null
	for current_hazard in proximity_dict:
		if closest_hazard == null or proximity_dict[current_hazard] < proximity_dict[closest_hazard]:
			closest_hazard = current_hazard
#		elif proximity_dict[current_hazard] < proximity_dict[closest_hazard]:
#			closest_hazard = current_hazard
	return closest_hazard
############################## End Retreat State ###############################
