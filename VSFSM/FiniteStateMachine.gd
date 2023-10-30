extends Node
class_name FiniteStateMachine

# use this signal to know when a state is changed
signal state_changed(new_state: State)

# use this signal to comunicate the nodes with elements
signal state_message(new_state: State, data: Dictionary)

var current_state: State
var machine_variables: Dictionary = {}

# starts the finite state machine at given state
func start_FSM(start_state:State):
	set_new_state(start_state)

# updated fsm's current state and checks the state. In that order
func _process(delta):
	if current_state:
		current_state.process(delta)
		_check_state_conditions();

# set new state and calls enter and exit methods for workflow
func set_new_state(new_state: State):
	if current_state:
		current_state._exit(self)
		current_state.on_exit()
		
	current_state = new_state
	state_changed.emit(current_state)
	
	current_state._enter(self)
	current_state.on_enter()

# set new state and calls enter and exit methods for workflow
func set_variable(variable_name: String, value):
	machine_variables[variable_name] = value
	
# checks all the conditions in current state
func _check_state_conditions():
	if !current_state: return
	var state:State = current_state._check_condition(machine_variables)
	if !state: return
	set_new_state(state)
