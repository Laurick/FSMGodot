# Very Simple Finite State Machine

[Versión español](#Descripción)

[English version](#Description)

---

## Descripción

Una biblioteca simple que implementa una maquina de estado finita en Godot. Nada más, nada menos.

### Uso

Importa la carpeta en zip desde la pestaña de **AssetLib** de godot como si fuera un addon . Si tienes mas dudas puedes ir a la [documentación oficial](https://docs.godotengine.org/es/4.x/community/asset_library/using_assetlib.html)

### Como empezar

Lo primero es crear estados para la maquina. Esto se hace heredando de la clase "State". Pongamos un ejemplo:

```gdscript
extends State

class_name StateSleepy

func _enter_tree():
	print("I'm sleepy... thanks you don't type anything")

func on_enter() -> void:
	finiteStateMachine.state_message.emit(self, {"message": "I'm sleepy... thanks you don't type anything"})

```

Este estado no hace gran cosa, escribe por consola y manda un mensaje a la máquina cuando se llega a ese estado. La idea es que se pueden crear stados mucho mas complejos:

```gdscript
extends State

class_name StateChill

var timeToTalk = 5.0
var asked = 0

func _enter_tree():
	print("All good, don't type")

func on_enter() -> void:
	asked = 0
	finiteStateMachine.state_message.emit(self, {"message": "All good, don't type"})

func on_exit() -> void:
	pass

func process(_delta):
	timeToTalk -= _delta
	if (timeToTalk < 0):
		print("How are you?")
		finiteStateMachine.state_message.emit(self, {"message": "How are you?"})
		timeToTalk = 5
		asked += 1
		self.finiteStateMachine.set_variable("ask", asked)

```

Una vez se tengan os estados, crea un nodo "FiniteStateMachine" y referencialo en el script que quieras. Ahora puedes añadir cada estado a la maquina y la condicion que se necesita para ir al siguiente estado. Las condiciones tienen varios atributos que la componen:

* variable_name -> nombre de la variable.

* value_needed -> valor necesario para cumplirla ( tiene que ser igual en tipo y valor )

* reseteable -> automáticamente al cambiar de estado la condicion volvera a su estado por defecto. La varaible con el nombre *variable_name* será null.

* one_shot -> automáticamente al cambiar de estado la condicion se eliminara de la transición si esta cumplida.

```gdscript
@onready var fsm:FiniteStateMachine = $FiniteStateMachine

func _ready():
	var stateChill = StateChill.new()
	var stateSleepy = StateSleepy.new()
	var stateAngry = StateAngry.new()
	var stateMad = StateMad.new()
	
	var conditionSilent = Condition.new()
	conditionSilent.variable_name = "ask"
	conditionSilent.value_needed = 3
	conditionSilent.reseteable = true
	
	var conditionType = Condition.new()
	conditionType.variable_name = "type"
	conditionType.value_needed = true
	conditionType.reseteable = true
	
	var conditionChill = Condition.new()
	conditionChill.variable_name = "timeout"
	conditionChill.value_needed = true
	conditionChill.reseteable = true
	
	stateChill.add_transition(stateSleepy, [conditionSilent], true)
	stateChill.add_transition(stateAngry, [conditionType], true)
	stateAngry.add_transition(stateMad, [conditionType], true)
	stateAngry.add_transition(stateChill, [conditionChill], true)
	stateMad.add_transition(stateChill, [conditionChill], true)
	stateSleepy.add_transition(stateAngry, [conditionType], true) 
```

Ten en cuenta que *one_shot* dentro de cada transicion hara que si se elimine si se navega al nodo objetivo. Ahora puedes inicar la maquina de estados con el metodo **start_FSM** y el estado de inicio que quieras.

```gdscript
func _ready():
	var stateChill = StateChill.new()

	(...)

	fsm.start_FSM(stateChill)
```

### Comunicación

La comunicación con la máquina de estados se hace usando las variables. Estas variables son las que se han definido previamente en las condiciones. Automaticamente la máquina cambiara si fuera necesario.

```gdscript
fsm.set_variable("type", true)
```

A la inversa, la maquina se comunica usando estas 2 señales.

```gdscript
fsm.state_changed.connect(clear_label, CONNECT_DEFERRED)
fsm.state_message.connect(update_label, CONNECT_DEFERRED)
```

La señales **state_changed** se llama cuando se cambia de un estado a otro y la señal de **state_message** se ejecuta cuando se necesite ( definida en los States custom )

Esta es la definición de las señales.

```gdscript
signal state_changed(new_state: State)
signal state_message(new_state: State, data: Dictionary)
```

### Métodos

#### State

```gdscript
func add_transition(state_to: State, conditions: Array[Condition], need_all_conditions_be_true: bool):
```

La función **add_transition** se usa para añadir transiciones de un estado (self) a otro (state_to). La máquina navegará de ese estado al siguiente si en un momento dado todas (need_all_conditions_be_true es True) o solamente 1 (need_all_conditions_be_true es False) de las condiciones están cumplidas.

```gdscript
func on_enter() -> void:
```

Sobreescribe la función **on_enter** para que se ejecuten y el código de esta función se ejecutará cuando se llega a ese estado.

```gdscript
func on_exit() -> void:
```

Sobreescribe la función **on_exit** para que se ejecuten y el código de esta función se ejecutará cuando se abandona ese estado.

```gdscript
func process(delta):
```

La función **process** es similar a la del nodo de Godot. Se llama cada frame y delta contiene la diferencia de tiempo entre este fram y el anterior. Sobreescribela para ejecutar dicho código solamente si el nodo esta activo.

#### Finite State Machine

```gdscript
func start_FSM(start_state:State)
```

La función **start_FSM** inicia la máquina de estados en el estado *start_state* y comenzara su ejecucion autónoma.

```gdscript
func set_new_state(new_state: State)
```

La función **set_new_state** cambia de forma forzosa la máquina de estados en el estado *new_state* . Debido a la naturaleza forzosa de la ejecución **NO** eliminará las condiciones o las transiciones marcadas como *one_shot*.

```gdscript
func set_variable(variable_name: String, value)
```

La función **set_variable** actualiza el valor dado de la variable con nombre *variable_name* y el valor *value*.

### Ejemplo de uso



---

## Description

A simple library that implements a finite state machine in Godot. Nothing more, nothing less.

### Use

Import the zip folder from the **AssetLib** tab of godot as if it were an addon. If you have more questions you can go to the [oficial documentation](https://docs.godotengine.org/en/4.x/community/asset_library/using_assetlib.html)

### Getting started

The first thing to do is to create states for the machine. This is done by inheriting from the **State** class. Let's take an example:

```gdscript
extends State

class_name StateSleepy

func _enter_tree():
	print("I'm sleepy... thanks you don't type anything")

func on_enter() -> void:
	finiteStateMachine.state_message.emit(self, {"message": "I'm sleepy... thanks you don't type anything"})
```

This state does not do much, it writes by console and sends a message to the machine when that state is reached. The idea is that much more complex states can be created:

```gdscript
extends State

class_name StateChill

var timeToTalk = 5.0
var asked = 0

func _enter_tree():
	print("All good, don't type")

func on_enter() -> void:
	asked = 0
	finiteStateMachine.state_message.emit(self, {"message": "All good, don't type"})

func on_exit() -> void:
	pass

func process(_delta):
	timeToTalk -= _delta
	if (timeToTalk < 0):
		print("How are you?")
		finiteStateMachine.state_message.emit(self, {"message": "How are you?"})
		timeToTalk = 5
		asked += 1
		self.finiteStateMachine.set_variable("ask", asked)
```

Once you have the states, create a **FiniteStateMachine** node and reference it in the script you want. Now you can add each state to the machine and the condition that is needed to go to the next state. The conditions have several attributes that compose it:

- variable_name -> variable name

- value_needed -> value needed to fulfill it ( it has to be equal in type and value )

- resettable -> automatically when changing the state the condition will return to its default state. The variable with name *variable_name* will be null.

- one_shot -> automatically when changing the state the condition will be removed from the transition if it is fulfilled.

```gdscript
@onready var fsm:FiniteStateMachine = $FiniteStateMachine

func _ready():
	var stateChill = StateChill.new()
	var stateSleepy = StateSleepy.new()
	var stateAngry = StateAngry.new()
	var stateMad = StateMad.new()

	var conditionSilent = Condition.new()
	conditionSilent.variable_name = "ask"
	conditionSilent.value_needed = 3
	conditionSilent.reseteable = true

	var conditionType = Condition.new()
	conditionType.variable_name = "type"
	conditionType.value_needed = true
	conditionType.reseteable = true

	var conditionChill = Condition.new()
	conditionChill.variable_name = "timeout"
	conditionChill.value_needed = true
	conditionChill.reseteable = true

	stateChill.add_transition(stateSleepy, [conditionSilent], true)
	stateChill.add_transition(stateAngry, [conditionType], true)
	stateAngry.add_transition(stateMad, [conditionType], true)
	stateAngry.add_transition(stateChill, [conditionChill], true)
	stateMad.add_transition(stateChill, [conditionChill], true)
	stateSleepy.add_transition(stateAngry, [conditionType], true) 
```

Note that *one_shot* within each transition will cause it to be removed if it navigates to the target node. Now you can start the state machine with the **start_FSM** method and the start state of your choice.

```gdscript
func _ready():
	var stateChill = StateChill.new()

	(...)

	fsm.start_FSM(stateChill)
```

### Comunicación

The communication with the state machine is done using the variables. These variables are the ones previously defined in the conditions. Automatically the machine will change if necessary.

```gdscript
fsm.set_variable("type", true)
```

On the other hand, the machine communicates using these 2 signals.

```gdscript
fsm.state_changed.connect(clear_label, CONNECT_DEFERRED)
fsm.state_message.connect(update_label, CONNECT_DEFERRED)
```

The **state_changed** signal is called when changing from one state to another and the **state_message** signal is executed when needed (defined in the States custom).

These are the signals defnition.

```gdscript
signal state_changed(new_state: State)
signal state_message(new_state: State, data: Dictionary)
```

### Methods

#### State

```gdscript
func add_transition(state_to: State, conditions: Array[Condition], need_all_conditions_be_true: bool):
```

The **add_transition** function is used to add transitions from one state (self) to another (state_to). The machine will navigate from that state to the next if at a given time all (need_all_conditions_be_true is True) or only 1 (need_all_conditions_be_true is False) of the conditions are met.

```gdscript
func on_enter() -> void:
```

Overwrite the **on_enter** function to be executed and the code of this function will be executed when that state is reached.

```gdscript
func on_exit() -> void:
```

It overwrites the **on_exit** function to be executed and the code of this function will be executed when leaving that state.

```gdscript
func process(delta):
```

The **process** function is similar to the Godot node. It is called every frame and delta contains the time difference between this fram and the previous one. Overwrite it to execute this code only if the node is active.

#### Finite State Machine

```gdscript
func start_FSM(start_state:State)
```

The **start_FSM** function starts the state machine in the *start_state* state and will start its autonomous execution.

```gdscript
func set_new_state(new_state: State)
```

The **set_new_state** function forces changes at the state machine to *new_state* state. Due to the forced nature of the execution will **NOT** remove conditions or transitions marked as *one_shot*.

```gdscript
func set_variable(variable_name: String, value)
```

The **set_variable** function updates the given value of the variable with the name *variable_name* and the value *value*.

### Use Example
