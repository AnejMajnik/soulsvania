extends State

# States
@export var jump_state: State
@export var idle_state: State

# Player reference
@export var player: Player

# Constants
const DAMAGE_HIT1: int = 5
const DAMAGE_HIT2: int = 10

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var combo_attack_area_2d: Area2D = %ComboAttackArea2D
@onready var collision_hit_1: CollisionPolygon2D = %CollisionHit1
@onready var collision_hit_2: CollisionPolygon2D = %CollisionHit2

func read_inputs() -> void:
	# Jump
	if Input.is_action_just_pressed("jump"):
		switch_state.emit(jump_state)
		
func enter_state() -> void:
	animated_sprite.stop()
	player.velocity.x = 0
	animation_player.play("attack_combo")
	collision_hit_1.disabled = false
	collision_hit_2.disabled = true
	
func exit_state() -> void:
	collision_hit_1.disabled = true
	collision_hit_2.disabled = true

func physics_update(_delta: float) -> void:	
	read_inputs()

func deal_damage_hit1():
	for body in combo_attack_area_2d.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.take_damage(DAMAGE_HIT1)
	collision_hit_1.disabled = true
	collision_hit_2.disabled = false
		
func deal_damage_hit2():
	for body in combo_attack_area_2d.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.take_damage(DAMAGE_HIT2)
	collision_hit_2.disabled = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack_combo":
		switch_state.emit(idle_state)
