extends Label






func new_bal():
	self.text = "Balance:                                 $" + str(GlobalData.cur_money - GlobalData.cur_cost)
	
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if (GlobalData.push_now):
		GlobalData.push_cost()
	new_bal()
	pass