extends Node

#for shop_menu.gd
var cur_money = 10000
var cur_cost = 0
var push_now = false

#for connection.gd and wirePlacing.gd
var placing_mode_on = false
var activeConnector = -1
var hovering_on = -1
var hovering_type = "Black"

func push_cost():
	cur_money = cur_money - cur_cost
	print(cur_money)
	cur_cost = 0
	push_now = false


#for Buttons
var item = 0



