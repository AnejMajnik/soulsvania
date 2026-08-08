extends State

@onready var slime_boss: SlimeBoss = owner
@onready var player: Player = Autoload.player_node

const SLAM_SPEED = 700
const FLY_SPEED = 420
const DAMAGE: int = 40
const AOE_DAMAGE: int = 20

enum Substate { JUMP, FLY, SLAM }
var current_state: Substate

# Fly
var fly_height: int = 200

@onready var slam_timer: Timer = $SlamTimer
@onready var ray_cast_down_left: RayCast2D = %RayCastDownLeft
@onready var ray_cast_down_right: RayCast2D = %RayCastDownRight
@onready var slam_aoe: Area2D = %SlamAOE

var recovery_time: float = 1.0

func enter_state() -> void:
	change_state(Substate.JUMP)
	
func jump() -> void:
	slime_boss.flip_gravity(false)
	var tween = create_tween()
	tween.tween_property(slime_boss, "position:y", slime_boss.global_position.y-fly_height, 0.75)
	tween.tween_callback(func(): change_state(Substate.FLY))
	
func fly_above_player() -> void:
	var direction
	if sign(player.global_position.x - slime_boss.global_position.x) > 0:
		direction = 1
	else:
		direction = -1
			
	slime_boss.velocity.x = FLY_SPEED * direction
	
func is_above_player() -> bool:
	return abs(slime_boss.global_position.x - player.global_position.x) < 8
	
func randomize_slam_timer() -> float:
	var time_amount = randf_range(0.1, 0.5)
	return time_amount
	
func slam() -> void:
	slime_boss.play_animation("land")
	slime_boss.velocity.y = SLAM_SPEED
	
func change_state(new_state: Substate) -> void:
	if new_state != current_state:
		current_state = new_state

	match current_state:
		Substate.JUMP:
			slime_boss.play_animation("fly")
			jump()
		Substate.FLY:
			slime_boss.velocity.y = 0
		Substate.SLAM:
			slime_boss.velocity.x = 0
			slam_timer.wait_time = randomize_slam_timer()
			slam_timer.start()
			
func physics_update(_delta: float) -> void:
	if current_state == Substate.FLY:
		fly_above_player()
		
		if is_above_player():
			change_state(Substate.SLAM)
	elif current_state == Substate.SLAM:
		if slime_boss.player_in_area != null:
			slime_boss.deal_damage(DAMAGE)
			
		if ray_cast_down_left.is_colliding() or ray_cast_down_right.is_colliding():
			slime_boss.flip_gravity(true)

func deal_damage_land():
	for body in slam_aoe.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(AOE_DAMAGE)

func _on_slam_timer_timeout() -> void:
	slam()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "land":
		state_finished.emit(recovery_time)
