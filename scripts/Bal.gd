extends Label
var money = 10000
var cur_cost = 0
var push_now = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func new_bal():
	self.text = "Balance:                                  $" + str(money - cur_cost)
	
	pass

func push_cost():
	money-= cur_cost
	cur_cost = 0
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (push_now):
		push_cost()
	new_bal()
	pass
