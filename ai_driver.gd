extends VehicleBody3D

# Nodes
var path_follow: PathFollow3D
var vehicle: VehicleBody3D

# Parameters
var waypoints = []
@export var max_speed = 1000.0 # Desired speed
@export var steering_angle = 0.0 # Current steering angle
var target_marker
@export var johnson_carrot = 15
@export var steer_slow_threshold = 0.1

# Timer for following the path
var timer
@export var racing_line_path: NodePath

# Variables to track car movement
var last_position: Vector3
var time_since_movement = 0.0
var reversing = false
var reverse_timer = 0.0

func _ready():
	# Initialize nodes
	var path = get_node(racing_line_path)
	path_follow = path.get_node("PathFollow3D")

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
	
	# Initialize last position
	last_position = global_transform.origin

func _input(event):
	pass

func _update_curve():
	var curve = Curve3D.new()
	for point in waypoints:
		curve.add_point(point)
	
	var path = get_node(racing_line_path)
	path.curve = curve

func _follow_path():
	if reversing:
		# If reversing, decrement the reverse timer
		reverse_timer -= 0.1
		if reverse_timer <= 0:
			reversing = false
	else:
		var path = get_node(racing_line_path)
		if path.curve.get_point_count() > 1:
			var car_position = global_transform.origin

			# Transform car position to path's local space using path's global transform inverse
			var target_position_local = path.global_transform.affine_inverse() * car_position
			
			var closest_distance = float(INF)
			var closest_offset = 0.0
			var path_length = path.curve.get_baked_length()
			var step_size = 10.0  # Smaller step size means more precise but more computationally expensive
			
			# Iterate along the path to find the closest point to the car's position
			for distance_along_path in range(0, path_length, step_size):
				var path_position = path.curve.sample_baked(distance_along_path)
				var distance_to_car = path_position.distance_to(target_position_local)
				
				if distance_to_car < closest_distance:
					closest_distance = distance_to_car
					closest_offset = distance_along_path
			
			path_follow.progress = closest_offset + johnson_carrot
				
			if path_follow.progress >= path.curve.get_baked_length():
				path_follow.progress = 0
			
			var target_position = path.curve.sample_baked(path_follow.progress, true)
			var direction_to_target = (target_position - global_transform.origin).normalized()
			var current_forward = -global_transform.basis.z.normalized()

			# CALCULATE STEERING ANGLE
			var dot_product = current_forward.dot(direction_to_target)
			var steering_angle = acos(dot_product) / 0.8
			var cross_product = current_forward.cross(direction_to_target)

			if cross_product.y < 0:
				steering_angle = -steering_angle

			# LIMIT TARGET SPEED IF NOT FACING RIGHT DIRECTION
			var angle_difference = abs(steering_angle)
			var target_speed = max_speed
			if angle_difference > steer_slow_threshold:
				target_speed = max_speed * (1.0 - angle_difference / PI)

			# check if the steering angle is greater than pi/2
			# if so reverse the car and set the steering angle to pi - steering angle
			if abs(steering_angle) > PI / 2:
				engine_force = -target_speed
				steering = PI - steering_angle
			else:
				engine_force = target_speed
				steering = steering_angle

			# Check if the car has moved
			if car_position.distance_to(last_position) < 1.0:
				time_since_movement += 0.1
				if time_since_movement >= 2.0:
					reversing = true
					reverse_timer = 2.0
					time_since_movement = 0.0
			else:
				time_since_movement = 0.0
				last_position = car_position

func _process(delta):
	if reversing:
		engine_force = -max_speed
		steering = 0
