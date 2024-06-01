extends Node2D

@export var WPBlue: Node2D
@export var WPRed: Node2D
@export var WPGreen: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	WPBlue.enabled = false
	WPRed.enabled = false
	WPGreen.enabled = false
	var existing_connections = get_tree().get_nodes_in_group("Connection")
	for con in existing_connections:
		on_connection_created(con)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_blue_enable():
	print("Let's blue!")
	WPBlue.enabled = true
	WPRed.enabled = false
	WPGreen.enabled = false
	
func on_red_enable():
	print("Red locked and loaded!")
	WPBlue.enabled = false
	WPRed.enabled = true
	WPGreen.enabled = false

func on_green_enable():
	print("green.")
	WPBlue.enabled = false
	WPRed.enabled = false
	WPGreen.enabled = true
	
func on_connection_created(connectionNode):
	if connectionNode.get_meta("Type") == "Blue":
		connectionNode.enable_blue.connect(on_blue_enable)
	elif connectionNode.get_meta("Type") == "Red":
		connectionNode.enable_red.connect(on_red_enable)
	elif connectionNode.get_meta("Type") == "Green":
		connectionNode.enable_green.connect(on_green_enable)
	
