extends State

# States
@export var chase_state: State

# Character references
@onready var slime_boss: SlimeBoss = owner
@onready var player: Player = Autoload.player_node

func enter_state() -> void:
	slime_boss.play_animation("idle")
	
func physics_update(_delta: float) -> void:
	if slime_boss.global_position.distance_to(player.global_position) < 690:
		switch_state.emit(chase_state)
