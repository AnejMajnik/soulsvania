extends Leaf
class_name ActionIdle

var started := false

@onready var boss = Autoload.boss_node

func tick(_delta: float) -> Status:
	if not started:
		started = true
		print("starting idle")
		boss.play_animation("idle")
	
	return Status.RUNNING
