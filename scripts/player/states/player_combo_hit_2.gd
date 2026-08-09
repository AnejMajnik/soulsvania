extends State

# States
@export var dash_state: State
@export var idle_state: State

@onready var player: Player = owner
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var hit_2_area: Area2D = %Hit2Area

const DAMAGE: int = 12

func enter_state() -> void:
	animation_player.play("combo_hit_2")

func read_inputs() -> void:
	# Dash
	if Input.is_action_just_pressed("dash") and player.dash_available:
		switch_state.emit(dash_state)
		
	# Slow movement
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		player.velocity.x = direction * player.SPEED/5
	else:
		player.velocity.x = 0

func physics_update(_delta: float) -> void:
	read_inputs()

func deal_damage():
	for body in hit_2_area.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.take_damage(DAMAGE)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "combo_hit_2":
		switch_state.emit(idle_state)
