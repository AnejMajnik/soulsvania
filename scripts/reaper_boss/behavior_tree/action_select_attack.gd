extends Leaf
class_name ActionSelectAttack

@export var attacks: Array[AttackData]

func tick(delta: float, blackboard: Blackboard) -> Status:
	if blackboard.get_value("selected_attack") != null:
		return Status.SUCCESS
	
	var distance: float = blackboard.get_value("distance_to_player")
	var stamina: float = blackboard.get_value("stamina")
	
	for attack in attacks:
		if attack == null:
			continue
		
		if stamina < attack.stamina_cost:
			continue
			
		if distance < attack.min_range or distance > attack.max_range:
			continue
			
		blackboard.set_value("selected_attack", attack)
		return Status.SUCCESS
		
	return Status.FAILURE
