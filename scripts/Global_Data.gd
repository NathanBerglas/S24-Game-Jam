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

var ConnectorLocationUp_red = []
var ConnectorLocationUp_green = []
var ConnectorLocationUp_blue = []

var ConnectorInstanceUp_red = []
var ConnectorInstanceUp_green = []
var ConnectorInstanceUp_blue = []

var WireUp_red = []
var WireUp_green = []
var WireUp_blue = []

#for wires/bridges

#plan is to store start and end coordinates of all wires so that we can check each newly created 
#line for intersections
###each line is represented by the start and end coordinates (this means each line is two indices)
var wire_coords = []
var bridge_coords = []




func intersect_at (start, end, lines):
	var line = []
	#if not intersect(start, end, lines):
	#	return false
	
	for n in range(0,len(lines) -1, 1):
		#the start and end are stored as positions of nodes
		#so you should be able to use start.x and start.y to access these values
		#i've got a tab open that should have a simple formula I'll do it some time in the morning
		var orient1 = orientation(start, end, lines[n])
		var orient2 = orientation(start, end, lines[n+1])
		var orient3 = orientation(lines[n], lines[n+1], start)
		var orient4 = orientation(lines[n], lines[n+1], end)
		if start == lines[n] or start == lines[n+1]:
			continue
		#trust the process or have a look at https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
		if orient1 * orient2 <= 0 and (orient1 != orient2) and orient3 * orient4 <= 0 and (orient3 != orient4):
				line.append(n)
		elif orient1 == orient2 and orient1 == orient3 and orient1 == orient4 and orient1 == 0:
				line.append(n)
	#now we have the correct line/lines that intersects, we now find each intersection point
	for n in line:
		var m1 = (end.y - start.y) / (end.x - start.y)
		var m2 = (lines[n+1].y - lines[n].y) / (lines[n+1].x - lines[n].x)
		var b1 = start.y - (m1 * start.x)
		var b2 = (lines[n].y - (m2 * lines[n].x))
		var px
		var py
		
		if m1 - m2 != 0:
			px = b1-b2 / m1-m2
			py = m1 * px + b1
		else:
			print("bad place")
			continue###this is wrong but for now it'll work
		var nearby = false
		for coord in bridge_coords:
			#30 is just a temporary value
			if coord.x - px + coord.y - py < 80:
				print("huh???")
				nearby = true
				break
		if not nearby:
			return true
		else:
			return false



#accepts start coordinates, end coordinates, and an array of lines to be checked against
func intersect (start, end, lines):
	for n in range(0,len(lines) -1, 1):
		#the start and end are stored as positions of nodes
		#so you should be able to use start.x and start.y to access these values
		#i've got a tab open that should have a simple formula I'll do it some time in the morning
		var orient1 = orientation(start, end, lines[n])
		var orient2 = orientation(start, end, lines[n+1])
		var orient3 = orientation(lines[n], lines[n+1], start)
		var orient4 = orientation(lines[n], lines[n+1], end)
		if start == lines[n] or start == lines[n+1]:
			continue
		#trust the process or have a look at https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
		if orient1 * orient2 <= 0 and (orient1 != orient2) and orient3 * orient4 <= 0 and (orient3 != orient4):
			print(n)
			return true
		elif orient1 == orient2 and orient1 == orient3 and orient1 == orient4 and orient1 == 0:
			print(n)
			return true
	return false

func orientation (p1, p2, p3):
	return (p2.y - p1.y) * (p3.x - p2.x) - (p3.y - p2.y) * (p2.x - p1.x)


