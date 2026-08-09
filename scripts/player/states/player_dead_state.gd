extends State

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var player: Player = owner

func enter_state() -> void:
	animation_player.play("dead")
	player.velocity.x = 0
