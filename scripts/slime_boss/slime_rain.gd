extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: Player = Autoload.player_node
@onready var rain_sound: AudioStreamPlayer2D = $RainSound

var velocity := Vector2.ZERO
var gravity_switch: bool = true

const DAMAGE: int = 20

func _ready() -> void:
	animated_sprite.play("fall")

func _physics_process(delta: float) -> void:
	if gravity_switch:
		velocity.y += gravity * delta
		position += velocity * delta
	

func _on_body_entered(body: Node2D) -> void:
	rain_sound.play()
	if body.is_in_group("foreground"):
		animated_sprite.play("hit")
		velocity.y = 0
		gravity_switch = false
	elif body.is_in_group("player"):
		velocity.y = 0
		gravity_switch = false
		player.take_damage(DAMAGE)
		queue_free()
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "hit":
		queue_free()
