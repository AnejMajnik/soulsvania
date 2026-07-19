extends State

# States
@export var idle_state: State
@export var jump_state: State
@export var attack_state: State
@export var dash_state: State

@export var player: Player

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func read_inputs() -> void:
	# Get input direction
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		animation_player.play("run")
		player.velocity.x = direction * player.SPEED
	else:
		animation_player.play("idle")
		player.velocity.x = move_toward(player.velocity.x, 0, player.DECCELERATION_SPEED)
		if player.velocity.x == 0:
			switch_state.emit(idle_state)
		
	# Jump
	if Input.is_action_just_pressed("jump"):
		switch_state.emit(jump_state)
		
	# Attack
	if Input.is_action_just_pressed("attack_combo"):
		switch_state.emit(attack_state)
		
	# Dash
	if Input.is_action_just_pressed("dash") and player.dash_available:
		switch_state.emit(dash_state)

func enter_state() -> void:
	animation_player.play("run")

func physics_update(_delta: float) -> void:
	read_inputs()
