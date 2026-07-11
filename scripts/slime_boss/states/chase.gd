extends State

# Character references
@onready var slime_boss: SlimeBoss = owner
@onready var player: Player = Autoload.player_node

# States
@export var attack_state: State

func enter_state() -> void:
	slime_boss.play_animation("move")
	
func chase() -> void:
	var direction
	if sign(player.global_position.x - slime_boss.global_position.x) > 0:
		direction = 1
	else:
		direction = -1
	
	slime_boss.velocity.x = direction * slime_boss.MOVE_SPEED
	
func end_condition() -> void:
	if slime_boss.global_position.distance_to(player.global_position) < 250:
		switch_state.emit(attack_state)
	
func physics_update(_delta: float) -> void:
	chase()
	end_condition()
