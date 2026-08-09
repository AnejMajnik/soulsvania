extends State

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func enter_state() -> void:
	animation_player.play("dead")
