extends "res://world.gd"

# Nodes
var path_follow: PathFollow3D
var vehicle: VehicleBody3D
var target_marker_mesh: MeshInstance3D

# Parameters
var waypoints = []
@export var max_speed = 2_000.0 # Desired speed
@export var steering_angle = 0.0 # Current steering angle
var target_marker
@export var distance_threshold = 30;
@export var some_angle_threshold = 0.5;
@export var path_speed = 100;
@export var some_distance_threshold = 60;

# Timer for following the path
var timer

func _ready():
	# Initialize nodes
	path = $Path3D
	path_follow = path.get_node("PathFollow3D")
	vehicle = $sedan
	target_marker_mesh = $MeshInstance3D
	
	# Initialize timer
	timer = Timer.new()
	timer.set_wait_time(0.1)
	timer.connect("timeout", _follow_path)
	add_child(timer)
	
	# Start the timer
	timer.start()

	# Connect input events
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_process_input(true)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = event.position
		
		# loop through 30 samples of the curve and make them waypoints
		var EPSILON = 10
		var num_checkpoints = 50
	
		var path_length = path.curve.get_baked_length()
		var segment_length = path_length / num_checkpoints
		
		for i in range(num_checkpoints + 1):
			var distance_along_path = segment_length * i
			var position_along_path = path.curve.sample_baked(distance_along_path)
			waypoints.append(position_along_path)
		
		_update_curve()
			
func _update_curve():
	var curve = Curve3D.new()
	for point in waypoints:
		curve.add_point(point)
	path.curve = curve

func _follow_path():
	var delta = 0.01
	if path.curve.get_point_count() > 1:
		# CHECK IF THE CAR IS CLOSER TO ANY OTHER POINT ON THE CURVE
		var closest_distance = INF
		var closest_progress = 0.0
		for i in range(path.curve.get_baked_length(), 0, -1):
			var point = path.curve.sample_baked(i)
			# var distance = vehicle.global_transform.origin.distance_to(point)
			# Use taxicab distance instead of Euclidean distance
			var distance = abs(vehicle.global_transform.origin.x - point.x) + abs(vehicle.global_transform.origin.z - point.z)
			if distance < closest_distance:
				closest_distance = distance
				closest_progress = i

		# SKIP TO THE NEAREST POINT IF CLOSER
		if closest_distance < distance_threshold and closest_progress > path_follow.progress:  # Adjust 'some_threshold' based on your requirements
			path_follow.progress = closest_progress

		# INCREMENT PROGRESS FOR MOVEMENT ONLY WHEN THE CAR IS WITHIN A SPECIFIC DISTANCE OF path_follow.progress
		if vehicle.global_transform.origin.distance_to(path.curve.sample_baked(path_follow.progress)) < some_distance_threshold:
			path_follow.progress += delta * path_speed
			
		if path_follow.progress >= path.curve.get_baked_length():
			path_follow.progress = 0
		
		var target_position = path.curve.sample_baked(path_follow.progress, true)
		var direction_to_target = (target_position - vehicle.global_transform.origin).normalized()
		var current_forward = -vehicle.global_transform.basis.z.normalized()  # Assuming Z- is forward

		# CALCULATE STEERING ANGLE
		var dot_product = current_forward.dot(direction_to_target)
		var steering_angle = acos(dot_product) / 0.8
		var cross_product = current_forward.cross(direction_to_target)

		# Adjust the steering based on cross product sign
		if cross_product.y < 0:
			steering_angle = -steering_angle

		vehicle.steering = move_toward(vehicle.steering, steering_angle, delta * 3.5)

		# LIMIT TARGET SPEED IF NOT FACING RIGHT DIRECTION
		var angle_difference = abs(steering_angle)
		var target_speed = max_speed
		if angle_difference > some_angle_threshold:  # Adjust 'some_angle_threshold' based on your requirements
			target_speed = max_speed * (1.0 - angle_difference / PI)  # Reduces speed based on steering angle

		vehicle.engine_force = target_speed
		
		target_marker_mesh.global_transform.origin = target_position

func _process(delta):

	"""if Input.is_action_pressed("ui_up"):
		vehicle.apply_engine_force(target_speed)
	elif Input.is_action_pressed("ui_down"):
		vehicle.apply_engine_force(-target_speed)
	else:
		vehicle.apply_engine_force(0)

	vehicle.steer(steering_angle)"""

