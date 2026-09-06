extends Leaf
class_name ActionAttack

@onready var boss = Autoload.boss_node

func tick(delta: float) -> Status:
	boss.play_animation("attack_combo")
	return Status.RUNNING
