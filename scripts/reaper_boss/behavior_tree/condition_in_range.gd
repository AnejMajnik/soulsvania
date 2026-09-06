extends Leaf
class_name ConditionInRange

@export var attack_range := 50
@onready var boss = Autoload.boss_node
@onready var player: Player = Autoload.player_node

func tick(delta: float) -> Status:
	print("boss: ", boss, " | player: ", player)
	var distance = boss.global_position.distance_to(player.global_position)
	if distance <= attack_range:
		return Status.SUCCESS
	return Status.FAILURE
