extends Node

var parent_node;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_pressed():
	var result = check_if_works()
	print("this connection setup has a validity of: " + str(result))
	return result

func check_if_works():
	var red_wires = processed_wires(GlobalData.WireUp_red, GlobalData.ConnectorLocationUp_red)
	var green_wires = processed_wires(GlobalData.WireUp_green, GlobalData.ConnectorLocationUp_green)
	var blue_wires = processed_wires(GlobalData.WireUp_blue, GlobalData.ConnectorLocationUp_blue)
	
	var required_red_locations = get_required_connections(GlobalData.ConnectorInstanceUp_red, GlobalData.ConnectorLocationUp_red)
	var required_green_locations = get_required_connections(GlobalData.ConnectorInstanceUp_green, GlobalData.ConnectorLocationUp_green)
	var required_blue_locations = get_required_connections(GlobalData.ConnectorInstanceUp_blue, GlobalData.ConnectorLocationUp_blue)

	var red_works = do_these_work(red_wires, required_red_locations)
	var green_works = do_these_work(green_wires, required_green_locations)
	var blue_works = do_these_work(blue_wires, required_blue_locations)

	var all_works = red_works and green_works and blue_works

	return all_works


# returns a wire list of all connection pairs locations e.g., [ ( [875, 343], [343, 320] ), (...) ] 
func processed_wires(wires, connector_locations):
	var result = []
	for index_pair in wires:
		result.append([connector_locations[index_pair[0]], connector_locations[index_pair[1]]])
	return result


# returns a list of the locations of all connector objects that must be visited e.g., [ [875, 343], [343, 320], e.g. ]
func get_required_connections(connector_objects, connector_locations):
	var result = []
	for index in connector_objects.size():
		if (not connector_objects[index].get_meta("fromPlacer_canBeDeleted")):
			result.append(connector_locations[index])
	return result


# returns true if all required connections are connected to each other by wires
func do_these_work(wires, required_connections):
	if (required_connections.size() <= 1): 
		return true
	
	# we will consider the first connection as the 'master' one and see if all other connections can reach it
	#  if so, all connections are connected to each other and we're true
	for connection in required_connections:
		if (not path_exists(connection, required_connections[0], wires)):
			return false

	return true


# returns true if a connection exists between locations x, y using wires
func path_exists(start, end, wires, used_wires = []):
		# if the start is the end, we're done
		if (start == end):
			return true
		
		# otherwise we check recursively
		var works = false;
		for wire in wires:
			# we mark wires as being used if we have used them and don't touch them again in this path
			if wire not in used_wires:

				# if the wire left connects to the start, see where that takes us
				if wire[0] == start:
					
					# mark this wire as used
					used_wires.append(wire)
					
					# make our new start the wire right and see if we can reach end
					#  if we already reached it, then leave it as is (hence the or)
					works = works or path_exists(wire[1], end, wires, used_wires); 	
				
				# same thing as above but checking to see if wire right can lead us anywhere
				if wire[1] == start:
					used_wires.append(wire) 										
					works = works or path_exists(wire[0], end, wires, used_wires);
					
		return works;
