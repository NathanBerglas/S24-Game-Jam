extends Node2D

@export var connection_scene: PackedScene

@export var cursor: Node2D

var connectorCount = 0
var placedConnectors = []
var placedConnectorsLocations = []
var cost = 0

var line_start: Vector2
var line_end: Vector2
var do_draw_line = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cursor.position = get_viewport().get_mouse_position()
	queue_redraw()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var connection_instance = connection_scene.instantiate()
			connection_instance.position = get_viewport().get_mouse_position()
			placedConnectors.append(connection_instance)
			placedConnectorsLocations.append(connection_instance.position)
			add_child(connection_instance)
			connectorCount += 1
			print(connectorCount)
		
func _draw():
	for i in range(connectorCount):
		if i != 0:
			print("let's a draw")
			draw_line(placedConnectorsLocations[i-1], placedConnectorsLocations[i], Color.RED, 15.0)
	if connectorCount != 0:
		draw_line(placedConnectorsLocations[connectorCount - 1], get_viewport().get_mouse_position(), Color.DARK_GOLDENROD, 10.0)
