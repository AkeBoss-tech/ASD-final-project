extends Control

@onready var practice_button = $VBoxContainer/practice
@onready var computer_button = $VBoxContainer/computer
@onready var two_player_button = $VBoxContainer/two_player
@onready var grand_prix_button = $VBoxContainer/grand_prix

# Called when the node enters the scene tree for the first time.
func _ready():
	practice_button.connect("pressed", _on_practice_button_pressed)
	computer_button.connect("pressed", _on_computer_button_pressed)
	two_player_button.connect("pressed",_on_two_player_button_pressed)
	grand_prix_button.connect("pressed", _on_grand_prix_button_pressed)

# Scene change functions
func _on_practice_button_pressed():
	get_tree().change_scene_to_file("res://practice.tscn")

func _on_computer_button_pressed():
	get_tree().change_scene_to_file("res://world_test.tscn")

func _on_two_player_button_pressed():
	get_tree().change_scene_to_file("res://two_player.tscn")

func _on_grand_prix_button_pressed():
	get_tree().change_scene_to_file("res://world.tscn")
