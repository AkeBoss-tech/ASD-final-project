extends VehicleBody3D

@export var max_steer = 0.7
const ENGINE_POWER = 100000
const BRAKE_POWER = 30000
const REVERSE_SPEED = -35000

signal speed_changed(speed)

@onready var camera_pivot = $CameraPivot
@onready var camera_3d = $CameraPivot/Camera3D
@onready var reverse_camera = $CameraPivot/ReverseCamera

# Reference to the AudioStreamPlayer nodes
@onready var audio_on = $On
@onready var audio_off = $Off

# Threshold to detect acceleration change
@export var accel_pitch_multi := 50
@export var decel_pitch_multi := 20

var look_at
var previous_speed = 0
@onready var tween = get_tree().create_tween().bind_node(self)


@export var MAX_SPEED = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURE)
	look_at = global_position
	audio_on.stop()
	audio_off.stop()

func _check_camera_switch():
	if linear_velocity.dot(transform.basis.z) < 0.01:
		camera_3d.current = true
	else:
		reverse_camera.current = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	steering = move_toward(steering, Input.get_axis("right_2", "left_2") * max_steer, delta * 2.5)
	
	engine_force = 0
	if Input.is_action_pressed("accelerate_2"):
		engine_force = ENGINE_POWER * delta
	elif Input.is_action_pressed("brake_2"):
		if linear_velocity.dot(linear_velocity.normalized()) > 0.01:
			engine_force = REVERSE_SPEED * delta * 0.5
		# engine_force = -BRAKE_POWER * delta
	elif Input.is_action_pressed("decelerate_2"):
		if linear_velocity.dot(linear_velocity.normalized()) > 0.01:
			engine_force = REVERSE_SPEED * delta
	
	apply_central_force(-transform.basis.z * engine_force)
	
	camera_pivot.global_position = camera_pivot.global_position.lerp(global_position, delta * 20.0)
	camera_pivot.transform = camera_pivot.transform.interpolate_with(transform, delta * 5.0)
	look_at = look_at.lerp(global_position + linear_velocity, delta * 5.0)
	camera_3d.look_at(global_position + linear_velocity)
	reverse_camera.look_at(global_position + linear_velocity)
	_check_camera_switch()

	var speed = linear_velocity.length()
	
	"""if abs(speed) > 1 and speed < MAX_SPEED:
		audio.pitch_scale = 2 * engine_force / ENGINE_POWER + 1
	elif speed < previous_speed and speed > 0:
		audio.pitch_scale = speed / MAX_SPEED + 0.5
		
	if abs(speed) <= 0.1:
		audio.stop()
	elif not audio.playing: 
		audio.play()"""
	
	previous_speed = speed
	
	emit_signal("speed_changed", speed)
	
	"""if Input.is_action_pressed("ui_cancel"):
		position = Vector3(position.x, position.y + 1, position.z)
		rotation = Vector3(rotation.x, rotation.y, 0)"""
		

func _process(delta):
	# Check if the car is accelerating or decelerating
	if engine_force > 0:
		if not audio_on.playing:
			audio_off.stop()
			audio_on.play()
	else:
		if not audio_off.playing:
			audio_on.stop()
			audio_off.play()
			
	audio_on.pitch_scale = linear_velocity.length() / accel_pitch_multi + 1
	audio_off.pitch_scale = linear_velocity.length() / decel_pitch_multi + 1

func _on_body_entered(body):
	$crash.play()


func _on_crash_finished():
	pass # Replace with function body.
