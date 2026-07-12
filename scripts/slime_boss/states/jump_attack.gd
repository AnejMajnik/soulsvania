extends State

@onready var slime_boss: SlimeBoss = owner
@onready var player: Player = Autoload.player_node

const DAMAGE: int = 60

enum Substate { JUMP, FLY, SLAM }
var current_state: Substate

# Fly
var fly_height: int = 200

# Slam
var slam_ready: bool = false
var slam_wait_time: float = 0.15
@onready var slam_timer: Timer = $SlamTimer
@onready var ray_cast_down_left: RayCast2D = %RayCastDownLeft
@onready var ray_cast_down_right: RayCast2D = %RayCastDownRight

var recovery_time: float = 1.5

func enter_state() -> void:
	change_state(Substate.JUMP)
	
func jump() -> void:
	slime_boss.flip_gravity(false)
	var tween = create_tween()
	tween.tween_property(slime_boss, "position:y", slime_boss.global_position.y-fly_height, 1)
	tween.tween_callback(func(): change_state(Substate.FLY))
	
func fly_above_player() -> void:
	var direction
	if sign(player.global_position.x - slime_boss.global_position.x) > 0:
		direction = 1
	else:
		direction = -1
			
	slime_boss.velocity.x = slime_boss.MOVE_SPEED * direction
	
func is_above_player() -> bool:
	if slime_boss.global_position.x > player.global_position.x-4 and slime_boss.global_position.x < player.global_position.x+4:
		return true
		
	return false
	
func slam() -> void:
	slime_boss.play_animation("land")
	slime_boss.velocity.y = slime_boss.SLAM_SPEED
	
func change_state(new_state: Substate) -> void:
	if new_state != current_state:
		current_state = new_state

	match current_state:
		Substate.JUMP:
			slime_boss.play_animation("fly")
			jump()
		Substate.FLY:
			fly_above_player()
		Substate.SLAM:
			slime_boss.velocity.x = 0
			slam_timer.wait_time = slam_wait_time
			slam_timer.start()
			
func physics_update(_delta: float) -> void:
	if current_state == Substate.FLY and is_above_player():
		change_state(Substate.SLAM)
	elif current_state == Substate.SLAM:
		if slime_boss.player_in_area != null:
			slime_boss.deal_damage(DAMAGE)
			
		if ray_cast_down_left.is_colliding() or ray_cast_down_right.is_colliding():
			slime_boss.flip_gravity(true)
			state_finished.emit(recovery_time)


func _on_slam_timer_timeout() -> void:
	slam()
