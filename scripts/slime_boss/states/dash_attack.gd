extends State

@onready var slime_boss: SlimeBoss = owner
@onready var player: Player = Autoload.player_node

@onready var telegraph_timer: Timer = $TelegraphTimer
@onready var ray_cast_left: RayCast2D = %RayCastLeft
@onready var ray_cast_right: RayCast2D = %RayCastRight

const DASH_SPEED = 700
const DAMAGE: int = 30

enum Substate { TELEGRAPH, ATTACK }
var current_state: Substate

var checking_ray: RayCast2D
var recovery_time: float = 0.75
var direction: int

func enter_state() -> void:
	change_substate(Substate.TELEGRAPH)

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
	slime_boss.velocity.x = direction * DASH_SPEED

func change_substate(new_state: Substate) -> void:
	if new_state != current_state:
		current_state = new_state
		
	match current_state:
		Substate.TELEGRAPH:
			check_direction()
			slime_boss.play_animation("dash_telegraph")
			telegraph_timer.start()
		Substate.ATTACK:
			slime_boss.play_animation("dash_attack")
			attack()

func physics_update(_delta: float) -> void:
	if current_state == Substate.ATTACK:
		if slime_boss.player_in_area != null:
			slime_boss.deal_damage(DAMAGE)
		
		if checking_ray.is_colliding():
			state_finished.emit(recovery_time)

func _on_telegraph_timer_timeout() -> void:
	change_substate(Substate.ATTACK)
