extends Control

@onready var view1 = $SubViewportContainer/SubViewport
@onready var view2 = $SubViewportContainer2/SubViewport
@onready var sub2 = $SubViewportContainer

var previous_size

# Called when the node enters the scene tree for the first time.
func _ready():
	update_size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var display_server = DisplayServer
	var screen_size_display_server = display_server.window_get_size(0)
	if previous_size != screen_size_display_server:
		update_size()
	
func update_size():
	var display_server = DisplayServer
	var screen_size_display_server = display_server.window_get_size(0)
	
	view1.size = Vector2(screen_size_display_server[0], screen_size_display_server[1] / 2)
	view2.size = Vector2(screen_size_display_server[0], screen_size_display_server[1] / 2)
	sub2.position = Vector2(0, screen_size_display_server[1] / 2)
	
	previous_size = screen_size_display_server
