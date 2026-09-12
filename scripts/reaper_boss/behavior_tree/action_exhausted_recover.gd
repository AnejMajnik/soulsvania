extends Leaf
class_name ActionExhaustedRecover

@onready var boss = Autoload.boss_node
@onready var player = Autoload.player_node
@onready var stamina_recovery_timer: Timer = %StaminaRecoveryTimer

@export var resume_threshold: int = 75
@export var speed: int = 50
@export var recovery_speed: int = 25
@export var ideal_distance: float = 150

var started: bool = false

func tick(delta: float, blackboard: Blackboard) -> Status:
	if !started:
		boss.play_animation("idle")
		stamina_recovery_timer.start()
		started = true
	
	if blackboard.get_value("stamina") >= resume_threshold:
		stamina_recovery_timer.stop()
		started = false
		return Status.SUCCESS
		
	return Status.RUNNING


func _on_stamina_recovery_timer_timeout() -> void:
	boss.recover_stamina(recovery_speed)
	stamina_recovery_timer.start()
