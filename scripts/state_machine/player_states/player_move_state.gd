extends State

# States
@export var idle_state: State
@export var jump_state: State
@export var attack_state: State

@export var player: Player

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var area_2d: Area2D = $"../../Area2D"

func read_inputs() -> void:
	# Get input direction
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		animated_sprite.play("run")
		player.velocity.x = direction * player.SPEED
	else:
		animated_sprite.play("idle")
		player.velocity.x = move_toward(player.velocity.x, 0, player.DECCELERATION_SPEED)
		if player.velocity.x == 0:
			switch_state.emit(idle_state)
		
	# Jump
	if Input.is_action_just_pressed("jump"):
		switch_state.emit(jump_state)
		
	# Attack
	if Input.is_action_just_pressed("attack_combo"):
		switch_state.emit(attack_state)

func enter_state() -> void:
	animated_sprite.play("run")

func physics_update(_delta: float) -> void:
	read_inputs()
