extends Leaf
class_name ActionSelectAttack

@export var attacks: Array[AttackData]

var previous_attack: AttackData

func tick(delta: float, blackboard: Blackboard) -> Status:
	if blackboard.get_value("selected_attack") != null:
		return Status.SUCCESS
	
	var distance: float = blackboard.get_value("distance_to_player")
	var stamina: float = blackboard.get_value("stamina")
	
	var candidates: Array[AttackData] = []
	var weights: Array[float] = []
	var total_weight: float = 0.0
	
	for attack in attacks:
		if attack == null:
			continue
		
		if stamina < attack.stamina_cost:
			continue
			
		if distance < attack.min_range or distance > attack.max_range:
			continue
			
		var range_width = attack.max_range - attack.min_range
		var distance_error = absf(distance - attack.ideal_range)
		
		# Calculates a weight based on the % of the available range the boss is from the ideal attack range
		var score = clampf(
			1.0 - distance_error / maxf(range_width, 0.001),
			0.0,
			1.0
		)
			
		# Gives every eligible attack at least a small chance
		var weight = maxf(score, 0.05)
		
		# If an attack was used as a previous attack, lowers the weight to prevent spamming same attack
		if attack == previous_attack:
			weight *= 0.25
			
		candidates.append(attack)
		weights.append(weight)
		total_weight += weight
	
	if candidates.is_empty():
		return Status.FAILURE
		
	var roll = randf() * total_weight
	var chosen_attack: AttackData = candidates.back()
	
	for i in range(candidates.size()):
		# It finds the correct roll by subtracting each roll, until we land in the correct zone (by being in negative)
		roll -= weights[i]
		
		if roll < 0.0:
			chosen_attack = candidates[i]
			break
	
	previous_attack = chosen_attack
	blackboard.set_value("selected_attack", chosen_attack)
	return Status.SUCCESS
