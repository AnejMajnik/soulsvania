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
	var weights: Dictionary = {}
	
	if slime_boss.health > slime_boss.max_health / 2:
		weights = {dash_attack: 0.5, jump_attack: 0.5}
	else:
		var far: bool = slime_boss.global_position.distance_to(player.global_position) > 150
		if far:
			weights = {dash_attack: 0.25, rain_attack: 0.25, beam_attack: 0.5}
		else:
			weights = {dash_attack: 0.4, rain_attack: 0.4, beam_attack: 0.2}
		
	return weighted_pick(weights)

func weighted_pick(weights: Dictionary) -> State:
	var total: float = 0.0
	for weight in weights.values():
		total += weight
	
	var rand_val: float = randf() * total
	var cumulative: float = 0.0
	
	for state in weights:
		cumulative += weights[state]
		if rand_val <= cumulative:
			return state
	return weights.keys()[-1]

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
