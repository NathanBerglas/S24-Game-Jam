extends Node2D

@export var WPBlue: Node2D
@export var WPRed: Node2D
@export var WPGreen: Node2D

@export var SwitchSound: AudioStreamPlayer

## Because it was really late and I spent way to long thinking about how to do multiple colours, this is the best I could come up with
## This is a master controller of the three wire colours, and works by enabling and disabling specific colours when needed
## The default is black, and means no colour selected

# Called when the node enters the scene tree for the first time.
func _ready():
	WPBlue.enabled = false # starts with each disabled
	WPRed.enabled = false
	WPGreen.enabled = false
	var existing_connections = get_tree().get_nodes_in_group("Connection") # Goes through each editor connection
	for con in existing_connections:
		on_connection_created(con) # Proccess each connection

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_blue_enable(): # Sends a silly message and enables only that colour
	print("Let's blue!")
	if not WPBlue.enabled: # Switch 
		SwitchSound.play(0.0)
	WPBlue.enabled = true
	WPRed.enabled = false
	WPGreen.enabled = false
	
func on_red_enable():
	print("Red locked and loaded!")
	if not WPRed.enabled: # Switch 
		SwitchSound.play(0.0)
	WPBlue.enabled = false
	WPRed.enabled = true
	WPGreen.enabled = false

func on_green_enable():
	print("green.") # my favorite
	if not WPGreen.enabled: # Switch 
		SwitchSound.play(0.0)
	WPBlue.enabled = false
	WPRed.enabled = false
	WPGreen.enabled = true
	
func on_connection_created(typeNode): # Sorts each node, and connects their on_colour_enable signal to the proper function
	if typeNode.get_meta("Type") == "Blue":
		typeNode.enable_blue.connect(on_blue_enable)
	elif typeNode.get_meta("Type") == "Red":
		typeNode.enable_red.connect(on_red_enable)
	elif typeNode.get_meta("Type") == "Green":
		typeNode.enable_green.connect(on_green_enable)
