extends State

@onready var slime_boss: SlimeBoss = owner

func enter_state() -> void:
	slime_boss.play_animation("dead")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "dead":
		slime_boss.queue_free()
