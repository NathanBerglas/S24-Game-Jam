extends Node2D

@export var done_button: Button

func _on_pressed():
	var result = done_button.check_if_works()
	print("From level: this connection setup has a validity of: " + str(result))
	if result:
		get_tree().change_scene_to_file("res://level_two.tscn") # Need to change to level one (or whatever current level should be)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
