extends Leaf
class_name ActionAttack

@onready var boss = Autoload.boss_node
var started: bool = false
var animation_finished: bool = false
@onready var attack_combo_area: Area2D = %AttackComboArea2D

@export var DAMAGE: int = 10
@export var DECCELERATION_SPEED: int = 20
@export var LUNGE_SPEED: int = 200

func deal_damage_combo():
	for body in attack_combo_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(DAMAGE)

func tick(delta: float) -> Status:
	if !started:
		boss.play_animation("attack_combo")
		boss.velocity.x = 0
		started = true
		
	boss.velocity.x = move_toward(boss.velocity.x, 0, DECCELERATION_SPEED)
	boss.move_and_slide()
	
	if animation_finished:
		started = false
		animation_finished = false
		return Status.SUCCESS
		
	return Status.RUNNING

func apply_lunge() -> void:
	var direction = boss.get_current_direction()
	boss.velocity.x = LUNGE_SPEED * direction

func attack_anim_finished() -> void:
	animation_finished = true
