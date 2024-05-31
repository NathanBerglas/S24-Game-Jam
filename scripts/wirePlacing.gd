extends Node2D

@export var connection_scene: PackedScene
@export var wire_scene: PackedScene

@export var cursor: Node2D

var connectorCount = 0
var placedConnectors = []
var placedConnectorsLocations = []
var wires: Array = []
@export var cost = 0
@export var additionalCost = 0

signal connectorDeleted
signal wireDeleted

var line_start: Vector2
var line_end: Vector2
var do_draw_line = false

var connectorPrice = 1000
var pricePerPixel = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	var preexisting = get_tree().get_nodes_in_group("Connection")
	for pCon in preexisting:
		placedConnectors.append(pCon)
		placedConnectorsLocations.append(pCon.position)
		connectorCount += 1
	#place_wire_begin()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if GlobalData.placing_mode_on:
		placing_wire()
	queue_redraw()

func place_wire_begin():
	GlobalData.placing_mode_on = true
	cursor.visible = true
	
func place_wire_end():
	GlobalData.placing_mode_on = false
	cursor.visible = false

func placing_wire():
	cursor.position = get_viewport().get_mouse_position()
	if (connectorCount >= 2):
		additionalCost = connectorPrice + get_viewport().get_mouse_position().distance_to(placedConnectorsLocations[GlobalData.activeConnector]) * pricePerPixel
		for placedConLoc in placedConnectorsLocations:
			if get_viewport().get_mouse_position().distance_to(placedConLoc) < 50:
				additionalCost -= connectorPrice
				cursor.position = placedConLoc
	if (additionalCost != 0):
		GlobalData.cur_cost = floor(additionalCost)

func _input(event):
	if GlobalData.placing_mode_on && event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var index = 0
		var skip = false
		for placedConLoc in placedConnectorsLocations:
			if get_viewport().get_mouse_position().distance_to(placedConLoc) < 50:
				if GlobalData.activeConnector != index:
					var wire_exists = false
					for wire in wires:
						if wire[0] == min(GlobalData.activeConnector, index) and wire[1] == max(GlobalData.activeConnector, index):
							wire_exists = true
					if not wire_exists:
						wires.append([min(GlobalData.activeConnector, index), max(GlobalData.activeConnector, index)])
						print("New wire, ", GlobalData.activeConnector, " to ", index)
						var wire_instance = wire_scene.instantiate()
						wire_instance.start_index = wires[wires.size() - 1][0]
						wire_instance.end_index = wires[wires.size() - 1][1]
						wire_instance.start_point = placedConnectorsLocations[wire_instance.start_index]
						wire_instance.end_point = placedConnectorsLocations[wire_instance.end_index]
						add_child(wire_instance)
						wire_instance.wire_deleted.connect(on_wire_deleted)
						GlobalData.activeConnector = index
				skip = true
			index += 1
		if not skip:
			var connection_instance = connection_scene.instantiate()
			connection_instance.set_meta("index", connectorCount)
			connection_instance.set_meta("fromPlacer_canBeDeleted", true)
			connection_instance.place_wire_begin_signal.connect(place_wire_begin)
			connection_instance.position = get_viewport().get_mouse_position()
			placedConnectorsLocations.append(connection_instance.position)
			placedConnectors.append(connection_instance)
			print("New connector")
			connectorCount += 1
			cost += connectorPrice
			if connectorCount >= 2:
				cost += connection_instance.position.distance_to(placedConnectorsLocations[GlobalData.activeConnector]) * pricePerPixel
				wires.append([min(GlobalData.activeConnector, connectorCount - 1), max(GlobalData.activeConnector, connectorCount - 1)])
				print("New auto wire, ", GlobalData.activeConnector, " to ", index)
				var wire_instance = wire_scene.instantiate()
				wire_instance.start_index = wires[wires.size() - 1][0]
				wire_instance.end_index = wires[wires.size() - 1][1]
				wire_instance.start_point = placedConnectorsLocations[wire_instance.start_index]
				wire_instance.end_point = placedConnectorsLocations[wire_instance.end_index]
				add_child(wire_instance)
				wire_instance.wire_deleted.connect(on_wire_deleted)
			add_child(connection_instance)
			GlobalData.activeConnector = connectorCount - 1
			GlobalData.push_now = true
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		place_wire_end()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_P:
		place_wire_begin()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_W:
		print(wires)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_C:
		print(placedConnectorsLocations)	
	elif not GlobalData.placing_mode_on && event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if GlobalData.hovering_on != -1 and placedConnectors[GlobalData.hovering_on].get_meta("fromPlacer_canBeDeleted"):
			print("We should be deleting: ", GlobalData.hovering_on)
			var windex = 0
			print("Wires: ", wires)
			while windex < wires.size():
				var wire = wires[windex]
				print("Begin process of wire, ", wire)
				if wire[0] == GlobalData.hovering_on or wire[1] == GlobalData.hovering_on:
					wires.remove_at(windex)
					print("Deletion of wire: ", wire)
					continue
				else:
					print("Kept wire: ", wire)
				if wire[0] > GlobalData.hovering_on:
					wire[0] -= 1
				if wire[1] > GlobalData.hovering_on:
					wire[1] -= 1
				windex += 1
				print("New wire: ", wire)
			wireDeleted.emit(GlobalData.hovering_on) #wireside
			if GlobalData.activeConnector == GlobalData.hovering_on:
				GlobalData.activeConnector = connectorCount - 2
			elif GlobalData.activeConnector > GlobalData.hovering_on:
				GlobalData.activeConnector -= 1
			placedConnectorsLocations.pop_at(GlobalData.hovering_on)
			placedConnectors.pop_at(GlobalData.hovering_on)
			connectorCount -= 1
			connectorDeleted.emit(GlobalData.hovering_on)

func _draw():
	if connectorCount != 0 and GlobalData.placing_mode_on and GlobalData.activeConnector != -1:
		draw_line(placedConnectorsLocations[GlobalData.activeConnector], get_viewport().get_mouse_position(), Color.DARK_GOLDENROD, 10.0)

func on_wire_deleted(start_index, end_index):
	var windex = 0
	for wire in wires:
		if wire[0] == start_index and wire[1] == end_index:
			wires.remove_at(windex)
			break
		windex += 1	
		
