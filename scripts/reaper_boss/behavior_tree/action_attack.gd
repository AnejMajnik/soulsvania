extends Leaf
class_name ActionAttack

@onready var boss = Autoload.boss_node
var started: bool = false
var animation_finished: bool = false

func tick(delta: float) -> Status:
	if !started:
		boss.play_animation("attack_combo")
		started = true
		
	if animation_finished:
		started = false
		animation_finished = false
		return Status.SUCCESS
		
	return Status.RUNNING

func attack_anim_finished() -> void:
	animation_finished = true
