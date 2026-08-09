extends State

# States
@export var idle_state: State
@export var move_state: State
@export var combo_attack_state: State
@export var dash_state: State

# Reference to player
@export var player: Player

# References
@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var can_double_jump: bool = true

func read_inputs():
	# Move left and right
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		player.velocity.x = direction * player.current_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.DECCELERATION_SPEED)
	
	# Double jump
	if Input.is_action_just_pressed("jump") and can_double_jump:
		jump()
		can_double_jump = false
		
	# Attack
	if Input.is_action_just_pressed("attack_combo"):
		switch_state.emit(combo_attack_state)

func jump():
	animation_player.stop()
	animation_player.play("jump")
	player.velocity.y = player.JUMP_VELOCITY

func enter_state() -> void:
	can_double_jump = true
	jump()

func physics_update(_delta: float) -> void:
	read_inputs()
	
	if player.is_on_floor():
		var direction := Input.get_axis("move_left", "move_right")
		if direction != 0:
			switch_state.emit(move_state)
		else:
			switch_state.emit(idle_state)
