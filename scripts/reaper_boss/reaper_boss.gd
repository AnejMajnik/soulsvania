extends CharacterBody2D

# Constants
const MOVE_SPEED = 225.00
const DECCELERATION_SPEED = 10

var max_health: int = 200
var health: int

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


signal health_changed(current: float, max: float)

func _ready() -> void:
	Autoload.boss_node = self
	
	health = max_health
	animated_sprite.play("idle")
	
func flash_take_damage() -> void:
	animated_sprite.material.set_shader_parameter("flash_color", Color(1.0, 1.0, 1.0, 1.0))
	var tween = create_tween()
	tween.tween_method(_set_flash, 1.0, 0.0, 0.2)

func _set_flash(value: float) -> void:
	animated_sprite.material.set_shader_parameter("flash_amount", value)

func take_damage(dmg: int) -> void:
	health -= dmg
	health_changed.emit(health, max_health)

	flash_take_damage()
