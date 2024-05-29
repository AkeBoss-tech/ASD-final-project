extends Control

@onready var view1 = $SubViewportContainer/SubViewport
@onready var view2 = $SubViewportContainer2/SubViewport

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	view1.size = Vector2(3, 2)
	var display_server = DisplayServer
	var screen_size_display_server = display_server.window_get_size(0)
	
	view1.size = Vector2(screen_size_display_server[0] / 2, screen_size_display_server[1])
	view2.size = Vector2(screen_size_display_server[0] / 2, screen_size_display_server[1])
