extends Leaf
class_name ConditionHasStamina

@export var attack_data: AttackData

func tick(delta: float, blackboard: Blackboard) -> Status:
	if blackboard.get_value("stamina") >= attack_data.stamina_cost:
		return Status.SUCCESS
	return Status.FAILURE
