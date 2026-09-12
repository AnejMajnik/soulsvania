extends CharacterBody2D

var max_health: int = 200
var health: int

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit: AudioStreamPlayer2D = $Sounds/Hit
@onready var behavior_tree: BTNode = %BehaviorTree
@onready var attack_combo_area: Area2D = %AttackComboArea2D

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
	
func flash_take_damage() -> void:
	animated_sprite.material.set_shader_parameter("flash_color", Color(1.0, 1.0, 1.0, 1.0))
	var tween = create_tween()
	tween.tween_method(_set_flash, 1.0, 0.0, 0.2)

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
	elif direction < 0:
		animated_sprite.flip_h = true
		attack_combo_area.position.x = -abs(attack_combo_area.position.x)
		attack_combo_area.scale.x = -1

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
	
	#apply_knockback()
	
func apply_knockback() -> void:
	var direction = sign(global_position.x - Autoload.player_node.global_position.x)
	velocity.x += direction * 100

func _physics_process(delta: float) -> void:
	behavior_tree.tick(delta)
	auto_flip_check()
