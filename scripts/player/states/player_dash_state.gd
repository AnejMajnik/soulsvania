extends State

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var player: Player = owner
@onready var dash_timer: Timer = $DashTimer

@export var idle_state: State
@export var move_state: State

const DASH_SPEED = 600

func enter_state() -> void:
	player.start_dash_cooldown()
	
	animation_player.play("dash")
	player.flip_gravity(false)
	player.velocity.y = 0
	dash()
	
func dash() -> void:
	var direction = player.get_current_direction()
	player.velocity.x = DASH_SPEED * direction
	dash_timer.start()
	

func finish() -> void:
	player.velocity.x = 0
	player.flip_gravity(true)
	
	# Move
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		switch_state.emit(move_state)
	else:
		switch_state.emit(idle_state)

func _on_dash_timer_timeout() -> void:
	finish()
