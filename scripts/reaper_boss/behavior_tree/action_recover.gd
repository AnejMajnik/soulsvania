extends Leaf
class_name ActionRecover

var started: bool = false
var finished: bool = false
@onready var boss = Autoload.boss_node
@onready var ac_recover_timer: Timer = %ACRecoverTimer

func tick(delta: float, blackboard: Blackboard) -> Status:
	if !started:
		boss.play_animation("idle")
		ac_recover_timer.start()
		started = true
	
	if finished:
		started = false
		finished = false
		return Status.SUCCESS
	
	return Status.RUNNING

func _on_ac_recover_timer_timeout() -> void:
	finished = true
