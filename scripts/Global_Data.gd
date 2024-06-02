extends Node

#for shop_menu.gd
var cur_money = 10000
var cur_cost = 0
var push_now = false

#for connection.gd and wirePlacing.gd
var placing_mode_on = false # Whether the player is placing nodes
var activeConnector = -1 # Which node in general is the one that the player is building wires from
## There is a flaw with this, as it was made before multiple colours. This is global for all wire_placing, and means that in the worst case, it can pass through the index of another colour
## This can cause out of bounds issues, as well as deleting, or placing wires over the wrong connections.
var hovering_on = -1 # What node the player has their mouse over. If none, -1
var hovering_type = "Black"  # What is the colour the player is hovering over

func push_cost():
	cur_money = cur_money - cur_cost
	print(cur_money)
	cur_cost = 0
	push_now = false


#for Buttons
var item = 0

#for grid points
var gridpoints = []






#for wires/bridges

#plan is to store start and end coordinates of all wires so that we can check each newly created 
#line for intersections
###each line is represented by the start and end coordinates (this means each line is two indices)
var wire_coords = []

#accepts start coordinates, end coordinates, and an array of lines to be checked against
func intersect (start, end, lines):
	for n in range(0,len(lines), 2):
		#the start and end are stored as positions of nodes
		#so you should be able to use start.x and start.y to access these values
		#i've got a tab open that should have a simple formula I'll do it some time in the morning
		pass




