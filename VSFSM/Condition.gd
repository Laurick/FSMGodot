class_name Condition

# variable to check on variables map at fsm
var variable_name: String

# value expected to be in map in order to fulfill the condition
var value_needed 

# use this is you want to reset the variable at fsm when change the state happens
var reseteable: bool = true

# use this is you want delete the condition after completion
var one_shot: bool = false

func _is_fullfilled(value) -> bool:
	return value_needed == value
