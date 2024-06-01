extends Node2D

@export var start_point: Vector2
@export var end_point: Vector2
@export var start_index: int
@export var end_index: int

@export var myArea: Area2D

var collision_polygon: CollisionPolygon2D

signal enable_red
signal enable_blue
signal enable_green

var mouse_hover = false

signal wire_deleted

func _ready():
	var wire_placing = get_parent()
	assert(wire_placing.is_in_group("wire_placing_g")) # this bad boy gotta be associated with a wire placer, cannot be alone
	wire_placing.connection_wireDeleted.connect(connection_wireDeleted) # Connects wire deletion by connection signal
	wire_placing.wireDeleted.connect(on_wire_deleted) # Connects wire deletion by click signal
	self.set_meta("Colour", wire_placing.get_meta("Colour").blend(Color(0.25, 0.25, 0.25, 0.5))) # Get parent colour, then add with dark grey 50% alpha
	self.set_meta("Type", wire_placing.get_meta("Type")) # Set type to whomever placed it
	collision_polygon = CollisionPolygon2D.new() # Creates a collision dynamically to fit the line
	var direction = (end_point - start_point).normalized()
	var orthogonal = direction.orthogonal() * 10
	collision_polygon.set_polygon(PackedVector2Array([start_point + orthogonal, start_point - orthogonal, end_point - orthogonal, end_point + orthogonal]))
	myArea.add_child(collision_polygon) # Adds collision it created
	print("New wireside: (", start_index, ", ", end_index, ")")
	assert(start_index != end_index) # Make sure wire is not connected to itself

# Draw the wire
func _draw():
	if mouse_hover and not GlobalData.placing_mode_on and GlobalData.hovering_on == -1: # If the wire is hovered over, not while placing wire
		draw_line(start_point, end_point, Color.DARK_GRAY, 20.0)
	draw_line(start_point, end_point, self.get_meta("Colour"), 10.0) # Once hover is draw, draw the line itself in its colour

func _input_event(viewport, event, shape_idx): # When the dynamic Area2D detects the mouse
	queue_redraw() # when you mvoe mouse from connection to wire, it doesn't redraw without this
	# Documented in connection script
	if event is InputEventMouseButton and event.pressed and not GlobalData.placing_mode_on: # clicked on
		print("Adjusting focus")
		if self.get_meta("Type") == "Red":
			print("Wire says red")
			enable_red.emit() 
		elif self.get_meta("Type") == "Green":
			print("you touch wire you go green!")
			enable_green.emit()
		elif self.get_meta("Type") == "Blue":
			print("blue is deemed by wire")
			enable_blue.emit()
		if event.button_index == MOUSE_BUTTON_RIGHT and GlobalData.hovering_on == -1: # Right mouse click
			wire_deleted.emit(start_index, end_index, self.get_meta("Type")) # Tell the wire controller it wishes to be rid of this world
			print("Ordering deletion of wire: (", start_index, ", ", end_index, ")")

func connection_wireDeleted(index): # This means any general connection is deleted, and if the wire is on it, it should be deleted
	if start_index == index or end_index == index: # If this wire is included in the connection that just got deleted
		print("Deleting wireside, because my start is: ", start_index, " and by end is: ", end_index)
		queue_free()
		return
	if start_index > index: # Adjusts index's to account for the removed connection
		start_index -= 1
	if end_index > index:
		end_index -= 1
	assert(start_index != end_index) # Should never trigger if math works (it triggers all the time)

func _on_area_2d_mouse_entered(): # For hover
	mouse_hover = true
	queue_redraw()

func _on_area_2d_mouse_exited(): # For hover
	mouse_hover = false
	queue_redraw()
	
func on_wire_deleted(sindex, eindex, type):
	if type != self.get_meta("Type"): # Ensure it is the correct type
		print("2 not me!: ", self.get_meta("Type"), " (", start_index, ", ", end_index, ")")
		return
	if start_index == sindex and end_index == eindex: # if this wire is the one to be deleted
		queue_free()
