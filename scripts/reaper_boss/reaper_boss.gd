extends CharacterBody2D

var max_health: int = 200
var health: int

var max_stamina: int = 100
var stamina: int

@onready var blackboard:= Blackboard.new()
@onready var player: Player = Autoload.player_node

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit: AudioStreamPlayer2D = $Sounds/Hit
@onready var behavior_tree: BTNode = %BehaviorTree

@onready var attack_combo_area: Area2D = %AttackComboArea2D
@onready var attack_teleport_area: Area2D = %AttackTeleportArea2D
@onready var attack_aoe_area: Area2D = %AttackAoeArea2D

signal health_changed(current: float, max: float)

func _enter_tree() -> void:
	Autoload.boss_node = self

func get_current_direction() -> int:
	if animated_sprite.flip_h == true:
		return -1
	else:
		return 1

func _ready() -> void:
	health = max_health
	stamina = max_stamina
	
	blackboard.set_value("boss", self)
	blackboard.set_value("player", player)
	blackboard.set_value("max_stamina", max_stamina)
	blackboard.set_value("selected_attack", null)
	blackboard.set_value("boss_is_attacking", false)
	
func spend_stamina(amount: int) -> void:
	if stamina - amount <= 0:
		stamina = 0
	else:
		stamina -= amount
	
	blackboard.set_value("stamina", stamina)
	
func recover_stamina(amount: int) -> void:
	if stamina + amount >= max_stamina:
		stamina = max_stamina
	else:
		stamina += amount
		flash_stamina_recovery()
		
	blackboard.set_value("stamina", stamina)
	
func flash_take_damage() -> void:
	animated_sprite.material.set_shader_parameter("flash_color", Color(1.0, 1.0, 1.0, 1.0))
	var tween = create_tween()
	tween.tween_method(_set_flash, 1.0, 0.0, 0.2)
	
func flash_stamina_recovery() -> void:
	animated_sprite.material.set_shader_parameter("flash_color", Color(0.0, 0.995, 0.428, 1.0))
	animated_sprite.material.set_shader_parameter("flash_opacity", 0.5)
	var tween = create_tween()
	tween.tween_method(_set_flash, 1.0, 0.0, 0.5)

func _set_flash(value: float) -> void:
	animated_sprite.material.set_shader_parameter("flash_amount", value)
	
func play_animation(anim_name: String) -> void:
	animation_player.stop()
	animation_player.play(anim_name)
	
func flip_sprite(direction) -> void:
	if direction > 0:
		animated_sprite.flip_h = false
		attack_combo_area.position.x = abs(attack_combo_area.position.x)
		attack_combo_area.scale.x = 1
		attack_teleport_area.position.x = abs(attack_teleport_area.position.x)
		attack_teleport_area.scale.x = 1
		attack_aoe_area.position.x = abs(attack_aoe_area.position.x)
		attack_aoe_area.scale.x = 1
	elif direction < 0:
		animated_sprite.flip_h = true
		attack_combo_area.position.x = -abs(attack_combo_area.position.x)
		attack_combo_area.scale.x = -1
		attack_teleport_area.position.x = -abs(attack_teleport_area.position.x)
		attack_teleport_area.scale.x = -1
		attack_aoe_area.position.x = -abs(attack_aoe_area.position.x)
		attack_aoe_area.scale.x = -1

func auto_flip_check():
	if velocity.x > 0:
		flip_sprite(1)
	elif velocity.x < 0:
		flip_sprite(-1)

func take_damage(dmg: int) -> void:
	health -= dmg
	health_changed.emit(health, max_health)

	flash_take_damage()
	hit.play()

func refresh_blackboard_values():
	blackboard.set_value("distance_to_player", global_position.distance_to(player.global_position))
	blackboard.set_value("stamina", stamina)

func _physics_process(delta: float) -> void:
	refresh_blackboard_values()
	behavior_tree.tick(delta, blackboard)
	auto_flip_check()
	print(animation_player.current_animation)
