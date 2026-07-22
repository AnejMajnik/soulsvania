extends State

# Character references
@onready var slime_boss: SlimeBoss = owner
@onready var player: Player = Autoload.player_node

@onready var attack_state_machine: StateMachine = $AttackStateMachine

@export var dash_attack: State
@export var recover_state: State
@export var beam_attack: State
@export var jump_attack: State
@export var rain_attack: State

var current_attack: State

func _ready() -> void:
	for substate in attack_state_machine.get_children():
		substate.state_finished.connect(_on_substate_finished)

func choose_attack() -> State:
	# If health above 50%
	if slime_boss.health > slime_boss.max_health/2:
		var rand_val = randf()
		if rand_val <= 0.5:
			return dash_attack
		else:
			return jump_attack
	# If health below 50%
	else:
		var rand_val = randf()
		if rand_val <= 0.33:
			return dash_attack
		elif rand_val <= 0.66:
			return rain_attack
		else:
			return beam_attack

func enter_state() -> void:
	attack_state_machine.set_physics_process(true)
	slime_boss.velocity.x = 0
	attack_state_machine.active_state = null
	current_attack = choose_attack()
	attack_state_machine.change_state(current_attack)
	
func exit_state() -> void:
	attack_state_machine.set_physics_process(false)

func _on_substate_finished(recovery_time: float) -> void:
	slime_boss.next_recovery_time = recovery_time
	switch_state.emit(recover_state)
