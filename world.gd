extends Node3D

var time = 0
var best_time = 999

# Path to the race track (Path3D node)
@onready var path = $Path3D

# Reference to your car object
@onready var car = $race2

var path_global_transform

# Array to store checkpoint areas
var checkpoints = []

# Number of checkpoints to generate
var num_checkpoints = 10

# Current checkpoint index
var current_checkpoint_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if not path or not car:
		print("Warning: Missing path or car node reference!")
	path_global_transform = path.global_transform
	car.connect("speed_changed", _on_car_speed_changed)
	
	generate_checkpoints()

func _on_car_speed_changed(speed):
	$HUD/speed.text = "Speed: " + str(round(speed)) + " units/sec"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not path or not car:
		return

	var car_position = car.global_transform.origin

	# Transform car position to path's local space using path's global transform inverse
	var car_position_local = path_global_transform.affine_inverse() * car_position
	
	# Calculate car progress percentage
	var progress_percent = get_car_progress_percent(car_position_local) * 100
	
	# Check for the escape key press
	if Input.is_action_pressed("ui_cancel"):
		car.global_transform.origin = checkpoints[current_checkpoint_index - 1].global_transform.origin
		car.global_transform.basis = checkpoints[current_checkpoint_index - 1].global_transform.basis
		car.linear_velocity = Vector3.ZERO
		car.angular_velocity = Vector3.ZERO
		
	time += delta
	$HUD/time.text = "TIME: " + str(time).pad_zeros(3).left(6) + " PROGRESS: " + str(round(progress_percent)) + "%"


func get_car_progress_percent(target_position_local):
	var path_curve = path.curve
	var closest_distance = float(INF)
	var closest_offset = 0.0
	var path_length = path_curve.get_baked_length()
	var step_size = 10.0  # Smaller step size means more precise but more computationally expensive
	
	# Iterate along the path to find the closest point to the car's position
	for distance_along_path in range(0, path_length, step_size):
		var path_position = path_curve.sample_baked(distance_along_path)
		var distance_to_car = path_position.distance_to(target_position_local)
		
		if distance_to_car < closest_distance:
			closest_distance = distance_to_car
			closest_offset = distance_along_path
	
	# Calculate the progress percentage
	var progress_percent = closest_offset / path_length
	return progress_percent

# Generate checkpoints along the Path3D
func generate_checkpoints():
	var EPSILON = 10
	
	var path_length = path.curve.get_baked_length()
	var segment_length = path_length / num_checkpoints
	
	for i in range(num_checkpoints + 1):
		var distance_along_path = segment_length * i
		var position_along_path = path.curve.sample_baked(distance_along_path)
		# Sample a point slightly ahead for tangent calculation
		var slightly_ahead_distance = distance_along_path + EPSILON  # Small epsilon value

		# Ensure we don't go beyond path length
		if slightly_ahead_distance > path.curve.get_baked_length():
			slightly_ahead_distance = path.curve.get_baked_length()

		var slightly_ahead_point = path.curve.sample_baked(slightly_ahead_distance)
		
		var checkpoint = Area3D.new()
		var collision_shape = CollisionShape3D.new()
		var shape = CylinderShape3D.new()
		
		# Configure the shape dimensions
		shape.height = 10
		shape.radius = 10
		collision_shape.shape = shape
		
		checkpoint.add_child(collision_shape)
		add_child(checkpoint)
		
		# Set the position of the checkpoint
		checkpoint.global_position = position_along_path
		checkpoint.look_at(slightly_ahead_point, Vector3.UP)
		
		# Connect the area_entered signal
		checkpoint.connect("body_entered", func(body): return _on_checkpoint_area_entered(body, checkpoint))
		
		# Add checkpoint to array
		checkpoints.append(checkpoint)
		
# Signal handler for checkpoint area entered
func _on_checkpoint_area_entered(body, checkpoint):
	if body == car:
		if checkpoints[current_checkpoint_index] == checkpoint:
			print("Car entered checkpoint ", current_checkpoint_index)
			current_checkpoint_index += 1
			if current_checkpoint_index >= num_checkpoints + 1:
				current_checkpoint_index = 0
				_on_start_body_entered(car)
		else:
			print("Checkpoint missed or out of order!")

func _on_start_body_entered(body):
	if body == car:
		print("Car crossed the start/finish line!")
		# Update lap time and check if it's the best time
		if time < best_time:
			best_time = time
		print("Current lap time: ", time)
		print("Best lap time: ", best_time)
		# Reset the lap timer
		time = 0
