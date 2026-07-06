extends State

# States
@export var jump_state: State
@export var idle_state: State

# Player reference
@export var player: Player

# Signals
signal hit

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D

func read_inputs() -> void:
	# Jump
	if Input.is_action_just_pressed("jump"):
		switch_state.emit(jump_state)
		
	# Jump
	if Input.is_action_just_pressed("jump"):
		switch_state.emit(jump_state)

func enter_state() -> void:
	player.velocity.x = 0
	animated_sprite.play("attack_combo")

func physics_update(_delta: float) -> void:	
	read_inputs()

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack_combo":
		switch_state.emit(idle_state)

func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite and animated_sprite.animation == "attack_combo":
		if animated_sprite.frame in [4, 8]:
			if player.current_enemy != null:
				hit.emit()
