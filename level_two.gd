extends Node2D

@export var done_button: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalData.cur_money = 40000
	set_viewport_scale(2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_pressed():
	var result = done_button.check_if_works()
	print("From level 2: this connection setup has a validity of: " + str(result))
	if result:
		get_tree().change_scene_to_file("res://level_three.tscn") # Need to change to level three (or whatever current level should be)

# Function to set the viewport scale
func set_viewport_scale(scale_factor):
	#var viewport = get_viewport()
	#viewport.set_size_override(true, viewport.get_size() * scale_factor)
	get_window().content_scale_size = Vector2i(scale_factor*1920, scale_factor*1080)


func _on_skip_button_pressed():
	get_tree().change_scene_to_file("res://level_three.tscn") # Need to change to level three (or whatever current level should be)
