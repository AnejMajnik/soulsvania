extends State

# States
@export var move_state: State
@export var jump_state: State
@export var attack_state: State

# Player reference
@export var player: Player

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D

func read_inputs() -> void:
	# Move
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		switch_state.emit(move_state)
		
	# Jump
	if Input.is_action_just_pressed("jump"):
		switch_state.emit(jump_state)
		
	# Attack
	if Input.is_action_just_pressed("attack_combo"):
		switch_state.emit(attack_state)

func enter_state() -> void:
	player.velocity.x = 0
	animated_sprite.play("idle")

func physics_update(_delta: float) -> void:	
	read_inputs()
