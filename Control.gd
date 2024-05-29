extends Control

@onready var view1 = $SubViewportContainer/SubViewport
@onready var view2 = $SubViewportContainer2/SubViewport

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get the screen size using the OS class
	# Get the screen size using the DisplayServer class (Godot 4.0+)
	var display_server = DisplayServer
	var screen_size_display_server = display_server.get_window_size()
	print("Screen size using DisplayServer: ", screen_size_display_server)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
