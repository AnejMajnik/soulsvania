extends Leaf
class_name ConditionInSight

@export var sight_range := 300
@onready var boss = Autoload.boss_node
@onready var player: Player = Autoload.player_node

func tick(delta: float) -> Status:
	var distance = boss.global_position.distance_to(player.global_position)
	if distance <= sight_range:
		return Status.SUCCESS
	return Status.FAILURE
