extends KinematicBody

### Node References ###
onready var head = get_node("Head")
onready var player = get_node("../Player")

### Movement vars ###
var walk_speed = 15
var acceleration = 0.2
var gravity = 75
var velocity = Vector3.ZERO

### Behavior Vars ###
enum {idle, advance, combat, retreat, cover}
#     0     1        2       3        4
var status = [0.0, 0.0, 0.0, 0.0, 0.0]
var weights = [0.1, 0.1, 0.1, 10, 0.1]
var active_state : int = idle

var proximity = []
var fov = []
var active_objective = Vector3.ZERO


func _process(delta) -> void:
# Run every frame of the game.
# Evaluates conditions and weighs the state machine accordingly.
	_check_proximity()
	var closest_body = _check_fov()

	# Determines the active state from the current weights.
	var heaviest_state = -1
	for current_state in range(0,4):
		if status[current_state] > heaviest_state:
			heaviest_state = status[current_state]
			active_state = current_state
	#print("Carl's active state is: ", active_state)
	match active_state:
		advance:
			var advance_vector = _face_towards(active_objective)
			move(delta, advance_vector) 
		combat:
			head.look_at(closest_body.transform.origin, Vector3.UP)
		retreat:
			# Future implimentations may involve additional logic to face
			# the enemy and move backwards, or full turn and run.
			var retreat_vector = _face_towards(proximity[0].transform.origin)
			move(delta, retreat_vector)
		cover:
			pass
		_: # The default state is to idle.
			move(delta)


func _face_towards(focus: Vector3):
# Will orient the body and head to face towards 'focus'.
# Returns the resulting direction vector.
	var direction = focus.direction_to(self.transform.origin)
	# self.rotation.y = direction.x
	# head.rotation.z = -(direction.y)
	
#	var y_rot = self.transform.origin.angle_to(direction)
#	var z_rot = self.transform.origin.angle_to(direction)
#	self.rotation.y = direction.x
#	head.rotation.z = -(direction.y)
	head.look_at(focus, Vector3.UP)
	return direction


func _check_proximity() -> KinematicBody:
# Check every body object in proximity list, updates state machine status
# according to their distance and quantity.
# Returns: The closest body in proximity.
	var closest_dist: float = 1000
	var closest_body: KinematicBody
	var proximity_sum: float = 0
	for body in proximity:
		var distance = self.transform.origin.distance_to(body.transform.origin)
		proximity_sum += distance
		if distance < closest_dist:
			closest_body = body
			closest_dist = distance
	status[retreat] = proximity_sum * weights[retreat]
	return closest_body


func _check_fov() -> KinematicBody:
# Goes over every body in 'fov' and changes the combat state status accordingly.
# Returns the closest body in FOV.
	status[combat] = len(fov)
	var closest_body = null
	var closest_dist = 1000
	for body in fov:
		var body_dist = self.translation.distance_to(body.translation)
		status[combat] += abs(body_dist - weights[combat])
		if body_dist < closest_dist:
			closest_body = body
			closest_dist = body_dist
	return closest_body


func move(delta: float, direction:= Vector3.ZERO) -> void:
# Given 'delta' (framerate), and 'direction' (Vector3),
# will apply gravity and motion to 'velocity' and move around
# the environment.
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		velocity.x += direction.x * acceleration
		velocity.z += direction.z * acceleration
	else:
		if velocity.length() > acceleration:
			velocity -= velocity.normalized() * acceleration
		else:
			velocity = Vector3.ZERO
	
	velocity.y -= gravity * delta
	velocity = move_and_slide(velocity)


# func retreat():
# # Function implimentation of the retreat case in _process()
# # Gets a dot product away from all bodies in proximity,
# # then calls move according to that vector.
# 	var retreat_vector: Vector3
# 	for body in proximity:
# 		retreat_vector *= self.transform.origin - body.transform.origin
# 	move(retreat_vector)


func _on_Proximity_body_entered(body):
	if body.is_in_group("player") or body.is_in_group("bot"):
		proximity.append(body)


func _on_Proximity_body_exited(body):
	if body.is_in_group("player") or body.is_in_group("bot"):
		proximity.erase(body)


func _on_Field_of_View_body_entered(body:Node):
	if body.is_in_group("player") or body.is_in_group("bot"):
		fov.append(body)


func _on_Field_of_View_body_exited(body:Node):
	if body.is_in_group("player") or body.is_in_group("bot"):
		fov.erase(body)
