extends State

# Character references
@onready var slime_boss: SlimeBoss = owner
@onready var player: Player = Autoload.player_node

# Raycasts
@onready var ray_cast_left: RayCast2D = %RayCastLeft
@onready var ray_cast_right: RayCast2D = %RayCastRight
@onready var ray_cast_down_left: RayCast2D = %RayCastDownLeft
@onready var ray_cast_down_right: RayCast2D = %RayCastDownRight

# Timers
@onready var rain_timer: Timer = $RainTimer
@onready var fly_timer: Timer = $FlyTimer
@onready var slam_timer: Timer = $SlamTimer

var recovery_time: float = 1.5
var slam_wait_time: float = 0.15

var slime_rain = preload("res://scenes/bosses/slime_rain.tscn")

# Constants
const SLAM_SPEED = 670
const FLY_SPEED = 500
const DAMAGE = 60

# States
enum Substate { JUMP, RAIN, FLY, SLAM }
var current_state: Substate

# Fly
var fly_height: int = 200
var direction: int = -1

func enter_state() -> void:
	change_state(Substate.JUMP)

func spawn_rain(pos: Vector2):
	var rain = slime_rain.instantiate()
	rain.global_position = pos
	get_tree().current_scene.add_child(rain)

func jump() -> void:
	slime_boss.flip_gravity(false)
	var tween = create_tween()
	tween.tween_property(slime_boss, "position:y", slime_boss.global_position.y-fly_height, 0.75)
	tween.tween_callback(func(): change_state(Substate.RAIN))
	
func fly_above_player() -> void:
	if sign(player.global_position.x - slime_boss.global_position.x) > 0:
		direction = 1
	else:
		direction = -1
			
	slime_boss.velocity.x = FLY_SPEED * direction
	
func is_above_player() -> bool:
	if slime_boss.global_position.x > player.global_position.x-4 and slime_boss.global_position.x < player.global_position.x+4:
		return true
		
	return false
	
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
		Substate.RAIN:
			rain_timer.start()
			fly_timer.start()
		Substate.SLAM:
			slime_boss.velocity.x = 0
			slam_timer.wait_time = slam_wait_time
			slam_timer.start()
			
func physics_update(_delta: float) -> void:
	if current_state == Substate.RAIN:
		if ray_cast_left.is_colliding():
			direction = 1
		elif ray_cast_right.is_colliding():
			direction = -1
	
		slime_boss.velocity.x = FLY_SPEED * direction
	elif current_state == Substate.FLY:
		fly_above_player()
		
		if is_above_player():
			change_state(Substate.SLAM)
	elif current_state == Substate.SLAM:
		if slime_boss.player_in_area != null:
			slime_boss.deal_damage(DAMAGE)
			
		if ray_cast_down_left.is_colliding() or ray_cast_down_right.is_colliding():
			slime_boss.flip_gravity(true)
			state_finished.emit(recovery_time)

func _on_rain_timer_timeout() -> void:
	spawn_rain(Vector2(slime_boss.global_position.x, slime_boss.global_position.y+20))
	if current_state == Substate.RAIN:
		rain_timer.start()


func _on_fly_timer_timeout() -> void:
	change_state(Substate.FLY)


func _on_slam_timer_timeout() -> void:
	slam()
