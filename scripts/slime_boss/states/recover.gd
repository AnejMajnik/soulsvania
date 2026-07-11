extends State

@onready var slime_boss: SlimeBoss = owner
@onready var recover_timer: Timer = $RecoverTimer
@onready var player: Player = Autoload.player_node

@export var chase_state: State
@export var attack_state: State

var recovered: bool = false

func enter_state() -> void:
	slime_boss.velocity.x = 0
	recovered = false
	slime_boss.play_animation("recover")
	recover_timer.start()

func physics_update(_delta: float) -> void:
	if slime_boss.global_position.distance_to(player.global_position) > 250 and recovered:
		switch_state.emit(chase_state)
	elif slime_boss.global_position.distance_to(player.global_position) < 250 and recovered:
		switch_state.emit(attack_state)

func _on_recover_timer_timeout() -> void:
	recovered = true
