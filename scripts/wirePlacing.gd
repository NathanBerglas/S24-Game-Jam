extends Node2D

@export var connection_scene: PackedScene
@export var wire_scene: PackedScene

@export var cursor: Node2D
@export var cursorOuterCircle: Sprite2D

@export var PlaceSound: AudioStreamPlayer
@export var DeleteSound: AudioStreamPlayer

var connectorCount = 0 # Counts the # of connectors. Creates incredibly disastrous bugs when not correct
var placedConnectors = [] # Stores instances
var placedConnectorsLocations = [] # Stores positions
var wires: Array = [] # stores wires as index -> inedx pairs, ie. [[0, 1], [1, 2], [0, 2]], requires first index to be < second index
@export var cost = 0
@export var additionalCost = 0

signal connectorDeleted
signal connectorCreated
signal connection_wireDeleted # To wire when a connection is removed
signal wireDeleted
signal wireCreated

var line_start: Vector2
var line_end: Vector2
var do_draw_line = false

var connectorPrice = 1000
var pricePerPixel = 1

@export var enabled = true # Here for the connector_control to enable and disable this colour

# Called when the node enters the scene tree for the first time.
func _ready():
	cursorOuterCircle.modulate = self.get_meta("Colour") # Sets colour of cursor
	var preexisting = get_tree().get_nodes_in_group(self.get_meta("Target")) # Gets all the pre-existing node in its colour
	for pCon in preexisting:
		placedConnectors.append(pCon) # Adds to placed connectors
		placedConnectorsLocations.append(pCon.global_position)
		pCon.set_meta("index", connectorCount) # Sets index of connectors
		pCon.place_wire_begin_signal.connect(place_wire_begin) # Connects wire signal
		connectorCount += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not enabled: # if disabled,d don't do anything
		return
	if GlobalData.placing_mode_on:
		placing_wire()
	queue_redraw()

func place_wire_begin(): # Toggles placing wire mode
	if not enabled:
		return
	GlobalData.placing_mode_on = true
	cursor.visible = true
	
func place_wire_end():
	if not enabled:
		return
	GlobalData.placing_mode_on = false
	cursor.visible = false


func placing_wire():
	if not enabled:
		return
	cursor.position = get_viewport().get_mouse_position() # move cursor to player mouse
	if (connectorCount >= 2): # Means a line must be drawn from active connector to possible new one
		additionalCost = connectorPrice + get_viewport().get_mouse_position().distance_to(placedConnectorsLocations[GlobalData.activeConnector]) * pricePerPixel
		for placedConLoc in placedConnectorsLocations: # For each placed connector location, check to see if it too close to where player wants to place it
			if get_viewport().get_mouse_position().distance_to(placedConLoc) < 50:
				additionalCost -= connectorPrice
				cursor.position = placedConLoc # Snaps to existing connector
	if (additionalCost != 0):
		GlobalData.cur_cost = floor(additionalCost)

func _input(event):
	if not enabled:
		return
	if GlobalData.placing_mode_on && event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT and event.pressed: # if a player places a wire or connector
		if len(wires) > 1 and GlobalData.intersect_at(placedConnectorsLocations[GlobalData.activeConnector], get_viewport().get_mouse_position(), placedConnectorsLocations): # Checks if valid
			print("Intersection!")
			return
		var index = 0 # Enumerates for loop
		var skip = false
		for placedConLoc in placedConnectorsLocations:
			if get_viewport().get_mouse_position().distance_to(placedConLoc) < 50: # If connecting a wire to placedConLoc/placedConnector[index]
				if GlobalData.activeConnector != index: # Checks player is not connecting a wire to itself
					var wire_exists = false # Checks if a player is re-adding a wire that already exists
					for wire in wires:
						if wire[0] == min(GlobalData.activeConnector, index) and wire[1] == max(GlobalData.activeConnector, index):
							wire_exists = true
					if not wire_exists: 
						wires.append([min(GlobalData.activeConnector, index), max(GlobalData.activeConnector, index)]) # Add a new wire to the array
						print("New wire, ", GlobalData.activeConnector, " to ", index)
						var wire_instance = wire_scene.instantiate()
						wire_instance.start_index = wires[wires.size() - 1][0]
						wire_instance.end_index = wires[wires.size() - 1][1]
						wire_instance.start_point = placedConnectorsLocations[wire_instance.start_index]
						wire_instance.end_point = placedConnectorsLocations[wire_instance.end_index]
						add_child(wire_instance) # Creats wire instance, data is set above
						PlaceSound.play(0.0)
						wireCreated.emit(wire_instance) # Connects to connector_control telling to sort and connect to the new wire
						GlobalData.wire_coords.append(wire_instance.start_point) # adds wire to global data
						GlobalData.wire_coords.append(wire_instance.end_point) 
						GlobalData.push_cost() # Finalizes wire cost
						wire_instance.wire_deleted.connect(on_wire_deleted)
						GlobalData.activeConnector = index # Sets the new active connector to the placed Connector the wire was just added to
				skip = true
			index += 1
		if not skip: # Ie. a new connector must be added. The previous wire code has not run due to no pre-existing connector
			var connection_instance = connection_scene.instantiate() # Creates a new connection and inits data
			connection_instance.set_meta("index", connectorCount)
			connection_instance.set_meta("Type", self.get_meta("Type"))
			connection_instance.set_meta("connectionColour", self.get_meta("Colour"))
			connection_instance.set_meta("fromPlacer_canBeDeleted", true)
			connection_instance.place_wire_begin_signal.connect(place_wire_begin)
			connection_instance.position = get_viewport().get_mouse_position()
			placedConnectorsLocations.append(connection_instance.position)
			placedConnectors.append(connection_instance)
			print("New connector")
			connectorCount += 1
			cost += connectorPrice
			if connectorCount >= 2: # If wire must automatically be added to new connection / is not the first connector
				cost += connection_instance.position.distance_to(placedConnectorsLocations[GlobalData.activeConnector]) * pricePerPixel
				wires.append([min(GlobalData.activeConnector, connectorCount - 1), max(GlobalData.activeConnector, connectorCount - 1)])
				print("New auto wire, ", GlobalData.activeConnector, " to ", index)
				var wire_instance = wire_scene.instantiate() # Creates wire just like above
				wire_instance.start_index = wires[wires.size() - 1][0]
				wire_instance.end_index = wires[wires.size() - 1][1]
				wire_instance.start_point = placedConnectorsLocations[wire_instance.start_index]
				wire_instance.end_point = placedConnectorsLocations[wire_instance.end_index]
				PlaceSound.play(0.0)
				wireCreated.emit(wire_instance)
				GlobalData.wire_coords.append(wire_instance.start_point)
				GlobalData.wire_coords.append(wire_instance.end_point)
				GlobalData.push_cost()
				wire_instance.wire_deleted.connect(on_wire_deleted)
				add_child(wire_instance) # Instantate connector now that wire is done
			add_child(connection_instance) # Instantate connector now that wire is done
			PlaceSound.play(0.0)
			connectorCreated.emit(connection_instance) # Connects to connector_control telling to sort and connect to the new connector
			GlobalData.activeConnector = connectorCount - 1 # Sets new active connector the new connector
			GlobalData.push_now = true
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE: # Stops wire placing
		place_wire_end()
	elif GlobalData.placing_mode_on && event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT and event.pressed: # same as escape
		place_wire_end()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_P:# and GlobalData.item == 1: # Shorcut. Designed for dev use, but may be implemented for player
		place_wire_begin()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_W: # Dev tool for showing wires script-side
		print(wires)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_C: # Dev tool for showing connectors and their locations
		print(placedConnectorsLocations)	
	elif not GlobalData.placing_mode_on && event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT and event.pressed: # Delete a connection
		## When this program recieves the order to delete a connection, it could be from any type, which is not good because then it would delete that index from the active colour, not the intended
		## This is here to prevent players from deleting connectors that are not active. It means sometimes a deletion does not go through, but it's better than crashing
		if GlobalData.hovering_type == self.get_meta("Type"): # Checks to see if the requested to be deleted connection is equal to this (the active) colour
			if GlobalData.hovering_on != -1 and placedConnectors[GlobalData.hovering_on].get_meta("fromPlacer_canBeDeleted"):
				deleteConnection()
		else:
			print("Deletion disregarded due to improper type") # It would be nice to replace this with a functionality that runs the input again once type is swtiched by the connection script

func deleteConnection():
	print("We should be deleting: ", GlobalData.hovering_on)
	connectorCount -= 1 #sehr wesentlich!!!
	var windex = 0 # Enumerate for the while loop
	print("Wires: ", wires)
	while windex < wires.size():
		var wire = wires[windex] # makeshift version of 'for wire in wires'
		## You use a for loop here because when a wire is removed it messes up the indexs and means wires are skipped. learnt the hard way
		print("Begin process of wire, ", wire)
		if wire[0] == GlobalData.hovering_on or wire[1] == GlobalData.hovering_on: # if this wire is the one the player is hovering on / ordered to be deleted
			wires.remove_at(windex)
			print("Deletion of wire: ", wire)
			continue
		else: 
			print("Kept wire: ", wire)
		if wire[0] > GlobalData.hovering_on: # readjust indexs for removed wire
			wire[0] -= 1
		if wire[1] > GlobalData.hovering_on:
			wire[1] -= 1
		windex += 1
		print("New wire: ", wire)
	connection_wireDeleted.emit(GlobalData.hovering_on) # Tells wire that it should delete itself. This is the node-side wire (called wireside), not script-side wire in the array (that has been previously deleted)
	if GlobalData.activeConnector == GlobalData.hovering_on: # If the player just deleted the active connector, then change to the most recently placed connector
		GlobalData.activeConnector = connectorCount - 1
	elif GlobalData.activeConnector > GlobalData.hovering_on: # Readjust index
		GlobalData.activeConnector -= 1
	placedConnectorsLocations.pop_at(GlobalData.hovering_on) # removed from array
	placedConnectors.pop_at(GlobalData.hovering_on)
	connectorDeleted.emit(GlobalData.hovering_on) # Tell all the connectors a connector is to be deleted
	DeleteSound.play(0.0)
			
func _draw():
	if not enabled:
		return
	if connectorCount != 0 and GlobalData.placing_mode_on and GlobalData.activeConnector != -1: # Draw the line from active connector to mouse, showing where wire will be placed
		draw_line(placedConnectorsLocations[GlobalData.activeConnector], get_viewport().get_mouse_position(), Color.DARK_GOLDENROD, 10.0)

func on_wire_deleted(start_index, end_index, type): # wire is specified ans start_index -> end_index
	if type != self.get_meta("Type"):
		print("not my type!: ", self.get_meta("Type"), " it should be this type: ", type, " or if not this is my enabled status: ", enabled)
		return
	var windex = 0 # enumerates wires
	for wire in wires:
		if wire[0] == start_index and wire[1] == end_index: # if current wires is the one to be deleted
			wires.remove_at(windex)
			wireDeleted.emit(start_index, end_index, type)
			DeleteSound.play(0.0)
			break
		windex += 1

func _on_shop_zone_mouse_entered():
	GlobalData.placing_mode_on = false
	cursor.visible = false
