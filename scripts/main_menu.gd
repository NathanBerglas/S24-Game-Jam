extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/test.tscn") # Need to change to level one (or whatever current level should be)


func _on_how_2_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/test.tscn") # Need to change to instructions scene


func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://scenes/test.tscn") # Need to change to options menu


func _on_quit_button_pressed():
	get_tree().quit()
