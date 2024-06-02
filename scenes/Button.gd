extends Button

func _ready():
	get_window().content_scale_size = Vector2i(1920, 1080)

func _on_pressed():
	get_tree().change_scene_to_file("res://scenes/tests/house_test.tscn")
