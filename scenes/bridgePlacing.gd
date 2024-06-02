extends Node2D


var bridge = preload("res://scenes/bridge.tscn")
var bridge_locations = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input (event) :
	#checks to ensure user has chosen "bridge" in the shop menu NOTE!!! CURRENTLY ==0 for testing purposes change to == 2
	if GlobalData.item == 2:
		#creates and places the bridge 'b' on the screen
		if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT and event.pressed and self.visible and GlobalData.cur_money >= 5000:
			var b = bridge.instantiate()
			b.position = get_global_mouse_position()
			b.visible = true
			add_child(b)
			GlobalData.bridge_coords.append(b.position)
			GlobalData.cur_money -= 5000



func _process(delta):
	if not self.get_child(1).get_global_rect().has_point(get_global_mouse_position()):
		self.visible = true

func _on_border_mouse_entered():
	self.visible = false
	pass # Replace with function body.

