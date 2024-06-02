extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	pass # Replace with function body.


func _process(delta):
	if (GlobalData.item == 2):
		self.visible = true
	else:
		self.visible = false
	position = get_viewport().get_mouse_position()
