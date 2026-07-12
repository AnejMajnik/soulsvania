extends ProgressBar

@onready var timer: Timer = $Timer
@onready var damage_bar: ProgressBar = $DamageBar

var health: int = 0 : set = _set_health

func init_health(_health):
	max_value = _health
	health = _health
	damage_bar.max_value = _health
	damage_bar.value = _health

func _set_health(new_health):
	health = min(max_value, new_health)
	value = health
	timer.start()
	
	if health <= 0:
		queue_free()

func _on_timer_timeout() -> void:
	damage_bar.value = health
