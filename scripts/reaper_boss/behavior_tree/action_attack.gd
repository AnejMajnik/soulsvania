extends Leaf
class_name ActionAttack

@onready var boss = Autoload.boss_node
@onready var player = Autoload.player_node
@onready var attack_combo_area: Area2D = %AttackComboArea2D

var started: bool = false
var animation_finished: bool = false

var attack_data: AttackData

@export var DECCELERATION_SPEED: int = 20
@export var LUNGE_SPEED: int = 250

@export var teleport_offset: float = 40.0

func teleport_behind_player() -> void:
	var player_facing = player.get_current_direction()
	
	boss.velocity = Vector2.ZERO
	boss.global_position = Vector2(player.global_position.x - player_facing * teleport_offset, Autoload.ground_reference.global_position.y)
	
	var face_player = sign(player.global_position.x - boss.global_position.x)
	boss.flip_sprite(face_player)
	
func deal_damage_combo():
	for body in attack_combo_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(attack_data.damage)
			
func deal_damage_teleport():
	for body in attack_combo_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(attack_data.damage)
			
func check_if_right_direction():
	var player_direction = sign(player.global_position.x - boss.global_position.x)
	var boss_facing = boss.get_current_direction()
	
	if player_direction != boss_facing:
		boss.flip_sprite(player_direction)

func tick(delta: float, blackboard: Blackboard) -> Status:
	if !started:
		attack_data = blackboard.get_value("selected_attack")
		
		if attack_data == null:
			return Status.FAILURE
		
		started = true
		animation_finished = false
		blackboard.set_value("boss_is_attacking", true)
		
		boss.velocity.x = 0
		boss.play_animation(attack_data.animation_name)
		check_if_right_direction()
		boss.spend_stamina(attack_data.stamina_cost)
		
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
