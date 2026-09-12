extends Leaf
class_name ConditionIsExhausted

@export var threshold: int = 20

func tick(delta: float, blackboard: Blackboard) -> Status:
	if blackboard.get_value("stamina") < threshold and !blackboard.get_value("boss_is_attacking"):
		return Status.SUCCESS
	return Status.FAILURE
