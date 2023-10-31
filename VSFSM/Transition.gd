class_name Transition
	
var need_all_conditions_be_true: bool
var one_shot_transition: bool
var state_transtision_to: State
var conditions_to_transition: Array[Condition]

func _init(state_to:State, need_all_conditions_needs_be_true:bool, one_shot:bool = false):
	state_transtision_to = state_to
	need_all_conditions_be_true = need_all_conditions_needs_be_true
	self.one_shot_transition = one_shot
	
func _add_condition(condition: Condition):
	conditions_to_transition.append(condition)

#check if transaction are fullilled with all the variables
func _is_fullfilled_conditions(variables: Dictionary) -> bool:
	if (need_all_conditions_be_true and conditions_to_transition.any(func is_condition_fullfilled(condition:Condition): return condition._is_fullfilled(variables.get(condition.variable_name)))) \
	or conditions_to_transition.all(func is_condition_fullfilled(condition:Condition): return condition._is_fullfilled(variables.get(condition.variable_name))):
		_reset_and_clear_conditions(variables)
		return true
	return false

func _reset_and_clear_conditions(variables: Dictionary):
	var indexes_to_remove = []
	for index in range(len(conditions_to_transition)):
		var condition:Condition = conditions_to_transition[index]
		if condition._is_fullfilled(variables.get(condition.variable_name)) and condition.one_shot:
			indexes_to_remove
		elif condition.reseteable: 
			variables[condition.variable_name] = null
	indexes_to_remove.reverse()
	for index_to_remove in indexes_to_remove:
		conditions_to_transition.remove_at(index_to_remove)
