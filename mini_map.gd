extends Camera3D

@export var target: NodePath
@onready var player = get_node(target)

@export var distance = 20
@export var zoom_out = 60

# Called when the node enters the scene tree for the first time.
func _ready():
	size = zoom_out

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = Vector3(player.position.x + distance * sin(player.rotation.y), size, player.position.z + distance * cos(player.rotation.y))
	rotation = Vector3(-90, player.rotation.y, 0)
	size = zoom_out
