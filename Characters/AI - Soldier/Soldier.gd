extends KinematicBody

###################-VARIABLES-####################

# Camera
export(float) var mouse_sensitivity = 8.0
# export(NodePath) var head_path = 'Head'
# export(NodePath) var cam_path = "Head/Camera"
export(float) var FOV = 80.0
var mouse_axis := Vector2()
onready var head: Spatial = get_node('Head')
onready var cam: Camera = get_node('Head/Camera')
# Move
var velocity := Vector3()
var direction := Vector3()
var move_axis := Vector2()
var snap := Vector3()
var sprint_enabled := true
var sprinting := false
# Walk
const FLOOR_MAX_ANGLE: float = deg2rad(46.0)
export(float) var gravity = 30.0
export(int) var walk_speed = 100
export(int) var sprint_speed = 16
export(int) var acceleration = 8
export(int) var deacceleration = 10
export(float, 0.0, 1.0, 0.05) var air_control = 0.3
export(int) var jump_height = 10
var _speed: int
var _is_sprinting_input := false
var _is_jumping_input := false

##################################################

# Called when the node enters the scene tree
# Needs to be changed to accomodate the requirements for the AI.
func _ready() -> void:
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	cam.fov = FOV
	pass


# Commented out because unused.
# # Called every frame. 'delta' is the elapsed time since the previous frame
# # This needs to change from accepting input from the player to accepting input calls from the state machine.
# func _process(_delta: float) -> void:
# #	move_axis.x = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
# #	move_axis.y = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
# #
# #	if Input.is_action_just_pressed("move_jump"):
# #		_is_jumping_input = true
# #
# #	if Input.is_action_pressed("move_sprint"):
# #		_is_sprinting_input = true
# 	pass

# Commented out because unused in current impl.
# # Called every physics tick. 'delta' is constant
# func _physics_process(delta: float) -> void:
# 	walk(delta)


# # Called when there is an input event
# # Should a generic AI have an input function? # Commented out because unused.
# func _input(event: InputEvent) -> void:
# #	if event is InputEventMouseMotion:
# #		mouse_axis = event.relative
# #		camera_rotation()
# 	pass


func move(delta: float, move_dir: Vector3):
	#head.look_at(move_dir)
	head.rotation.y = move_dir.y
	self.rotation.x = move_dir.x
	#print("move() FUNCTION IS BEING CALLED!!!!")
	if is_on_floor():
		snap = -get_floor_normal() - get_floor_velocity() * delta
		
		# Workaround for sliding down after jump on slope
		if move_dir.y < 0:
			move_dir.y = 0
		
		#jump()
	else:
		# Workaround for 'vertical bump' when going off platform
		if snap != Vector3.ZERO && velocity.y != 0:
			move_dir.y = 0
		
		snap = Vector3.ZERO
		
		move_dir.y -= gravity * delta
	
	#sprint(delta)
	
	#accelerate(delta)
	
	move_dir = move_and_slide_with_snap(move_dir * walk_speed, snap, Vector3.UP, true, 4, FLOOR_MAX_ANGLE)
	_is_jumping_input = false
	_is_sprinting_input = false


# # Walks, handles collisions and angles across surfaces in the environment.	
# func walk(delta: float) -> void:
# 	direction_input()
	
# 	if is_on_floor():
# 		snap = -get_floor_normal() - get_floor_velocity() * delta
		
# 		# Workaround for sliding down after jump on slope
# 		if velocity.y < 0:
# 			velocity.y = 0
		
# 		jump()
# 	else:
# 		# Workaround for 'vertical bump' when going off platform
# 		if snap != Vector3.ZERO && velocity.y != 0:
# 			velocity.y = 0
		
# 		snap = Vector3.ZERO
		
# 		velocity.y -= gravity * delta
	
# 	sprint(delta)
	
# 	accelerate(delta)
	
# 	velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true, 4, FLOOR_MAX_ANGLE)
# 	_is_jumping_input = false
# 	_is_sprinting_input = false

# Commented out because unused.
# # Handles camera rotation.
# # At the moment follows mouse movement as called by _input().
# func camera_rotation() -> void:
# #	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
# #		return
# #	if mouse_axis.length() > 0:
# #		var horizontal: float = -mouse_axis.x * (mouse_sensitivity / 100)
# #		var vertical: float = -mouse_axis.y * (mouse_sensitivity / 100)
# #
# #		mouse_axis = Vector2()
# #
# #		rotate_y(deg2rad(horizontal))
# #		head.rotate_x(deg2rad(vertical))
# #
# #		# Clamp mouse rotation
# #		var temp_rot: Vector3 = head.rotation_degrees
# #		temp_rot.x = clamp(temp_rot.x, -90, 90)
# #		head.rotation_degrees = temp_rot
# 	pass


# # Gets and normalizes current transform as a vector as a base for movement and aiming.
# func direction_input() -> void:
# 	direction = Vector3()
# 	var aim: Basis = get_global_transform().basis
# 	if move_axis.x >= 0.5:
# 		direction -= aim.z
# 	if move_axis.x <= -0.5:
# 		direction += aim.z
# 	if move_axis.y <= -0.5:
# 		direction -= aim.x
# 	if move_axis.y >= 0.5:
# 		direction += aim.x
# 	direction.y = 0
# 	direction = direction.normalized()
	
# 	mouse_axis = move_axis
	
# #	print("move_axis: ", move_axis)
# #	print("direction: ", direction)

# # Handles movement accelerations and friction applications on ground and in air.
# func accelerate(delta: float) -> void:
# 	# Where would the player go
# 	var _temp_vel: Vector3 = velocity
# 	var _temp_accel: float
# 	var _target: Vector3 = direction * _speed
	
# 	_temp_vel.y = 0
# 	if direction.dot(_temp_vel) > 0:
# 		_temp_accel = acceleration
		
# 	else:
# 		_temp_accel = deacceleration
	
# 	if not is_on_floor():
# 		_temp_accel *= air_control
	
# 	# Interpolation
# 	_temp_vel = _temp_vel.linear_interpolate(_target, _temp_accel * delta)
	
# 	velocity.x = _temp_vel.x
# 	velocity.z = _temp_vel.z
	
# 	# Make too low values zero
# 	if direction.dot(velocity) == 0:
# 		var _vel_clamp := 0.01
# 		if abs(velocity.x) < _vel_clamp:
# 			velocity.x = 0
# 		if abs(velocity.z) < _vel_clamp:
# 			velocity.z = 0


# # Jumps.
# func jump() -> void:
# 	if _is_jumping_input:
# 		velocity.y = jump_height
# 		snap = Vector3.ZERO


# # Handles the speed change from walking to sprinting and back.
# func sprint(delta: float) -> void:
# 	if can_sprint():
# 		_speed = sprint_speed
# 		cam.set_fov(lerp(cam.fov, FOV * 1.05, delta * 8))
# 		sprinting = true
		
# 	else:
# 		_speed = walk_speed
# 		cam.set_fov(lerp(cam.fov, FOV, delta * 8))
# 		sprinting = false

# # Checks if sprinting is currently a valid option. (currently moving forward and on the ground).
# func can_sprint() -> bool:
# 	return (sprint_enabled and is_on_floor() and _is_sprinting_input and move_axis.x >= 0.5)
