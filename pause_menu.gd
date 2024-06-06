extends Control

@onready var resume = $MarginContainer/VBoxContainer/Resume
@onready var restart = $MarginContainer/VBoxContainer/Restart
@onready var back = $MarginContainer/VBoxContainer/Back

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if resume.button_pressed:
		hide()
		get_tree().paused = false
	
	if restart.button_pressed:
		hide()
		get_tree().paused = false
		get_tree().reload_current_scene()
		
	if back.button_pressed:
		hide()
		get_tree().paused = false
		get_tree().change_scene_to_file("res://menu_bg.tscn")
