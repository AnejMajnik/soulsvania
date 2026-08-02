extends State

@onready var player: Player = owner
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export var idle_state: State
@export var dash_state: State
@export var combo_continue: State

func read_inputs() -> void:
	# Attack - combo continue
	if Input.is_action_just_pressed("attack_combo"):
		switch_state.emit(combo_continue)
	
	# Jump
	if Input.is_action_just_pressed("dash") and player.dash_available:
		switch_state.emit(dash_state)

func physics_update(_delta: float) -> void:
	read_inputs()

func enter_state() -> void:
	animation_player.play("combo_hit_1_recovery")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "combo_hit_1_recovery":
		switch_state.emit(idle_state)
