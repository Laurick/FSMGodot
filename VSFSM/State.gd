extends Node
class_name State

var transitions: Array[Transition] = []
var finiteStateMachine: FiniteStateMachine

# Called when the state is the current state.
func on_enter() -> void:
	pass

# Called when the state leaves as the current state. Used by user
func on_exit() -> void:
	pass

# Called amolst every frame when the state is the current. Used by user
func process(_delta):
	pass

# add transaction from this state to that state when one or all conditions are fullfilled
func add_transition(state_to: State, conditions: Array[Condition], need_all_conditions_be_true: bool):
	var transition:Transition = Transition.new(state_to, need_all_conditions_be_true)
	for condition in conditions:
		transition._add_condition(condition)
	transitions.append(transition)

# Called when the state leaves as the current state. Used privately
func _enter(parent: FiniteStateMachine):
	finiteStateMachine = parent
	parent.add_child(self)

# Called amolst every frame when the state is the current. Used privately
func _exit(parent: FiniteStateMachine):
	finiteStateMachine = null
	parent.remove_child(self)

# check all the transations to find witch are fullfilled. Will pick the first entered if two or more are fulfilled. returns null if there is no transaction fullfilled
func _check_condition(variables: Dictionary) -> State:
	var transactions_fullfiled:Array[Transition] = transitions.filter(func(transition:Transition): return transition._is_fullfilled_conditions(variables))
	if transactions_fullfiled.is_empty():
		return null
	var transaction_fullfilled:Transition = transactions_fullfiled.front(); # safe
	var next_state = transaction_fullfilled.state_transtision_to 
	if transaction_fullfilled.one_shot_transition:
		transitions.erase(transaction_fullfilled)
	return next_state

func _remove_one_shot_transactions():
	var indexes_to_remove = []
