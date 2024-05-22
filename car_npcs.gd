extends "res://world.gd"

# Nodes
var path_follow: PathFollow3D
var vehicle: VehicleBody3D
#var target_marker_mesh: MeshInstance3D

# Parameters
var waypoints = []
@export var max_speed = 1000.0 # Desired speed
@export var steering_angle = 0.0 # Current steering angle
var target_marker
@export var johnson_carrot = 15
@export var steer_slow_threshold = 0.1

# Timer for following the path
var timer

func _ready():
	# Initialize nodes
	path = $RacingLine
	path_follow = path.get_node("PathFollow3D")
	vehicle = $sedan
#	target_marker_mesh = $MeshInstance3D
	
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
	var path_speed = 0
	
	if path.curve.get_point_count() > 1:
		var car_position = vehicle.global_transform.origin

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
		var direction_to_target = (target_position - vehicle.global_transform.origin).normalized()
		var current_forward = -vehicle.global_transform.basis.z.normalized()

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
			vehicle.engine_force = -target_speed
			vehicle.steering = PI - steering_angle
		else:
			vehicle.engine_force = target_speed
			vehicle.steering = steering_angle
		
#		target_marker_mesh.global_transform.origin = target_position

func _process(delta):
	# vehicle.steering = move_toward(vehicle.steering, Input.get_axis("right", "left") * 0.8, delta * 2.5)
	pass
