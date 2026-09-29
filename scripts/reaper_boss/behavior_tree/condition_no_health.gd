extends Leaf

var boss = Autoload.boss_node

func tick(delta: float, blackboard: Blackboard) -> Status:
	if blackboard.get_value("boss_health") <= 0:
		return Status.SUCCESS
		
	return Status.FAILURE
