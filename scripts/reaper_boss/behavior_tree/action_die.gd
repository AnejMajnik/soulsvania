extends Leaf

@onready var boss = Autoload.boss_node

var started = false
var finished = false

func tick(delta: float, blackboard: Blackboard) -> Status:
	if !started:
		boss.velocity.x = 0
		boss.velocity.y = 0
		boss.play_animation("die")
		started = true
	
	if finished:
		finished = false
		started = false
		boss.die()
		return Status.SUCCESS
	
	return Status.RUNNING
	
func die_anim_finished():
	finished = true
