extends Leaf
class_name ConditionInRange

@export var attack_range := 75
@onready var boss = Autoload.boss_node
@onready var player: Player = Autoload.player_node

func tick(delta: float, blackboard: Blackboard) -> Status:
	var distance = blackboard.get_value("distance_to_player")
	if distance <= attack_range:
		return Status.SUCCESS
	return Status.FAILURE
