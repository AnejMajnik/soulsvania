extends State

@onready var slime_boss: SlimeBoss = owner
@onready var player: Player = Autoload.player_node

@onready var telegraph_timer: Timer = $TelegraphTimer
@onready var ray_cast_left: RayCast2D = %RayCastLeft
@onready var ray_cast_right: RayCast2D = %RayCastRight

enum Substates { TELEGRAPH, ATTACK }
var current_state: Substates

var checking_ray: RayCast2D
var direction

func enter_state() -> void:
	change_substate(Substates.TELEGRAPH)

func check_direction() -> void:
	if sign(player.global_position.x - slime_boss.global_position.x) > 0:
		direction = 1
		slime_boss.flip_sprite(false)
		checking_ray = ray_cast_right
	else:
		direction = -1
		slime_boss.flip_sprite(true)
		checking_ray = ray_cast_left
		
func attack() -> void:
	slime_boss.velocity.x = direction * slime_boss.DASH_SPEED

func change_substate(new_state: Substates) -> void:
	if new_state != current_state:
		current_state = new_state
		
	match current_state:
		Substates.TELEGRAPH:
			check_direction()
			slime_boss.play_animation("dash_telegraph")
			telegraph_timer.start()
		Substates.ATTACK:
			slime_boss.play_animation("dash_attack")
			attack()

func physics_update(_delta: float) -> void:
	if current_state == Substates.ATTACK and checking_ray.is_colliding():
		state_finished.emit()

func _on_telegraph_timer_timeout() -> void:
	change_substate(Substates.ATTACK)
