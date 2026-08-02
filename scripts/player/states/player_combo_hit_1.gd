extends State

# States
@export var dash_state: State
@export var combo_recover: State
@export var combo_continue: State

# Player reference
@onready var player: Player = owner

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var hit_1_area: Area2D = %Hit1Area

# Constants
const DAMAGE: int = 5

var continue_combo: bool = false

func read_inputs() -> void:
	# Attack - combo continue
	if Input.is_action_just_pressed("attack_combo"):
		continue_combo = true
	
	# Jump
	if Input.is_action_just_pressed("dash") and player.dash_available:
		switch_state.emit(dash_state)

func enter_state() -> void:
	continue_combo = false
	player.velocity.x = 0
	animation_player.play("combo_hit_1")

func physics_update(_delta: float) -> void:
	read_inputs()
	
func deal_damage():
	for body in hit_1_area.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.take_damage(DAMAGE)
			
func choose_state():
	if continue_combo:
		switch_state.emit(combo_continue)
	else:
		switch_state.emit(combo_recover)
