extends Leaf
class_name ActionChase

@export var attack_range := 75
@export var speed := 200
@onready var boss = Autoload.boss_node
@onready var player: Player = Autoload.player_node

func tick(delta: float) -> Status:
	boss.play_animation("move")
	
	var distance = boss.global_position.distance_to(player.global_position)
	
	if distance <= attack_range:
		return Status.SUCCESS
		
	var direction = (player.global_position - boss.global_position).normalized()
	boss.velocity = direction * speed
	boss.move_and_slide()
	
	return Status.RUNNING
