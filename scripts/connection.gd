extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position = get_viewport().get_mouse_position()


func _input(event):
	if (event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
		self.instantiate()
		
