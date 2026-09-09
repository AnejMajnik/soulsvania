extends Leaf
class_name ConditionInRange

@export var attack_range := 75
@onready var boss = Autoload.boss_node
@onready var player: Player = Autoload.player_node

func tick(delta: float) -> Status:
	var distance = boss.global_position.distance_to(player.global_position)
	if distance <= attack_range:
		return Status.SUCCESS
	return Status.FAILURE
