extends CharacterBody2D

var max_health: int = 200
var health: int

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit: AudioStreamPlayer2D = $Sounds/Hit
@onready var behavior_tree: BTNode = %BehaviorTree

signal health_changed(current: float, max: float)

func _enter_tree() -> void:
	Autoload.boss_node = self

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
	
func flip_sprite(value: bool) -> void:
	animated_sprite.flip_h = value

func auto_flip_check():
	if velocity.x > 0:
		flip_sprite(false)
	elif velocity.x < 0:
		flip_sprite(true)

func take_damage(dmg: int) -> void:
	health -= dmg
	health_changed.emit(health, max_health)

	flash_take_damage()
	hit.play()

func _physics_process(delta: float) -> void:
	behavior_tree.tick(delta)
	auto_flip_check()
