extends State

# States
@export var jump_state: State
@export var idle_state: State

# Player reference
@export var player: Player

# Signals
signal hit

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D

func read_inputs() -> void:
	# Jump
	if Input.is_action_just_pressed("jump"):
		switch_state.emit(jump_state)
		

func enter_state() -> void:
	animated_sprite.stop()
	player.velocity.x = 0
	animation_player.play("attack_combo")

func physics_update(_delta: float) -> void:	
	read_inputs()

func deal_damage():
	if player.current_enemy != null:
		hit.emit()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack_combo":
		switch_state.emit(idle_state)
