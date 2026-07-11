extends State

# Character references
@onready var slime_boss: SlimeBoss = owner
@onready var player: Player = Autoload.player_node

@onready var attack_state_machine: StateMachine = $AttackStateMachine

@export var dash_attack: State
@export var recover_state: State

var current_attack: State

func _ready() -> void:
	for substate in attack_state_machine.get_children():
		substate.state_finished.connect(_on_substate_finished)

func choose_attack() -> State:
	return dash_attack

func enter_state() -> void:
	attack_state_machine.set_physics_process(true)
	slime_boss.velocity.x = 0
	attack_state_machine.active_state = null
	current_attack = choose_attack()
	attack_state_machine.change_state(current_attack)
	
func exit_state() -> void:
	attack_state_machine.set_physics_process(false)

func _on_substate_finished() -> void:
	switch_state.emit(recover_state)
