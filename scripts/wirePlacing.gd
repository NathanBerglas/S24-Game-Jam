extends Node2D

@export var connection_scene: PackedScene

@export var cursor: Node2D

var connectorCount = 0
var placedConnectors = []
var placedConnectorsLocations = []
var wires: Array = []
@export var cost = 0
@export var additionalCost = 0

var line_start: Vector2
var line_end: Vector2
var do_draw_line = false

var connectorPrice = 1000
var pricePerPixel = 1

var activeConnector = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cursor.position = get_viewport().get_mouse_position()
	if (connectorCount >= 2):
		additionalCost = connectorPrice + get_viewport().get_mouse_position().distance_to(placedConnectorsLocations[activeConnector]) * pricePerPixel
		for placedConLoc in placedConnectorsLocations:
			if get_viewport().get_mouse_position().distance_to(placedConLoc) < 50:
				additionalCost -= connectorPrice
				cursor.position = placedConLoc
	if (additionalCost != 0):
		GlobalData.cur_cost = floor(additionalCost)
	queue_redraw()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var index = 0
			var skip = false
			for placedConLoc in placedConnectorsLocations:
				if get_viewport().get_mouse_position().distance_to(placedConLoc) < 50:
					wires.append([connectorCount - 1, index])
					skip = true
				index += 1
			if not skip:
				var connection_instance = connection_scene.instantiate()
				connection_instance.position = get_viewport().get_mouse_position()
				placedConnectors.append(connection_instance)
				placedConnectorsLocations.append(connection_instance.position)
				connectorCount += 1
				cost += connectorPrice
				if connectorCount >= 2:
					cost += connection_instance.position.distance_to(placedConnectorsLocations[connectorCount - 2]) * pricePerPixel
					wires.append([connectorCount - 2, connectorCount - 1])
				add_child(connection_instance)
				activeConnector = connectorCount - 1
				GlobalData.push_now = true

func _draw():
	for wire in wires:
		draw_line(placedConnectorsLocations[wire[0]], placedConnectorsLocations[wire[1]], Color.RED, 15.0)
	if connectorCount != 0:
		draw_line(placedConnectorsLocations[activeConnector], get_viewport().get_mouse_position(), Color.DARK_GOLDENROD, 10.0)
