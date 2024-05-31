extends Node2D

@export var start_point: Vector2
@export var end_point: Vector2
@export var start_index: int
@export var end_index: int

@export var myArea: Area2D

var collision_polygon: CollisionPolygon2D

var mouse_hover = false

signal wire_deleted

func _ready():
	z_index = -1
	var wire_placing = get_parent()
	if wire_placing:
		wire_placing.wireDeleted.connect(on_wireDeleted)
	collision_polygon = CollisionPolygon2D.new()
	var direction = (end_point - start_point).normalized()
	var orthogonal = direction.orthogonal() * 10
	collision_polygon.set_polygon(PackedVector2Array([start_point + orthogonal, start_point - orthogonal, end_point - orthogonal, end_point + orthogonal]))
	myArea.add_child(collision_polygon)
	print("New wireside: (", start_index, ", ", end_index, ")")
	assert(start_index != end_index)

# Draw the wire
func _draw():
	if mouse_hover and not GlobalData.placing_mode_on and GlobalData.hovering_on == -1:
		draw_line(start_point, end_point, Color.DARK_GRAY, 20.0)
	draw_line(start_point, end_point, Color.RED, 10.0)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT and not GlobalData.placing_mode_on and GlobalData.hovering_on == -1:
		wire_deleted.emit(start_index, end_index)
		print("Ordering deletion of wire: (", start_index, ", ", end_index, ")")
		queue_free()
	else:
		queue_redraw()

func on_wireDeleted(index):
	if start_index == index or end_index == index:
		print("Deleting wireside, because my start is: ", start_index, " and by end is: ", end_index)
		queue_free()
		return
	if start_index > index:
		start_index -= 1
	if end_index > index:
		end_index -= 1
	assert(start_index != end_index)

func _on_area_2d_mouse_entered():
	mouse_hover = true
	queue_redraw()

func _on_area_2d_mouse_exited():
	mouse_hover = false
	queue_redraw()
