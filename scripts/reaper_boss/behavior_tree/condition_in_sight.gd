extends Leaf
class_name ConditionInSight

@export var sight_range := 300
@onready var boss = Autoload.boss_node
@onready var player: Player = Autoload.player_node

func tick(delta: float, blackboard: Blackboard) -> Status:
	var distance = blackboard.get_value("distance_to_player")
	if distance <= sight_range:
		return Status.SUCCESS
	return Status.FAILURE
