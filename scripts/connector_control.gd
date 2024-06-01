extends Node2D

@export var WPBlue: Node2D
@export var WPRed: Node2D
@export var WPGreen: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	WPBlue.enabled = false
	WPRed.enabled = false
	WPGreen.enabled = false
	var existing_Bconnections = get_tree().get_nodes_in_group("ConnectionBlue")
	for bCon in existing_Bconnections:
		bCon.enable_blue.connect(on_blue_enable)
	var existing_Rconnections = get_tree().get_nodes_in_group("ConnectionRed")
	for rCon in existing_Rconnections:
		rCon.enable_red.connect(on_red_enable)
	var existing_Gconnections = get_tree().get_nodes_in_group("ConnectionGreen")
	for gCon in existing_Gconnections:
		gCon.enable_green.connect(on_green_enable)

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
