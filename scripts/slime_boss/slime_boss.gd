class_name SlimeBoss extends CharacterBody2D

# Constants
const MOVE_SPEED = 200.0
const DECCELERATION_SPEED = 15

var max_health: int = 200
var health: int
var next_recovery_time: float
var gravity_switch: bool = true
var can_deal_damage: bool = true

var player_in_area: Player

@onready var player: Player = Autoload.player_node
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var health_bar: ProgressBar = %HealthBar
@onready var area_2d: Area2D = $Area2D
@onready var damage_timer: Timer = $DamageTimer
@onready var slime_hit: AudioStreamPlayer2D = %SlimeHit

func _ready() -> void:
	health = max_health
	health_bar.init_health(health)
	
	state_machine.start()

func flash_white() -> void:
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(3, 3, 3, 1), 0.05)
	tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1, 1), 0.1)

func take_damage(dmg: int) -> void:
	health -= dmg
	health_bar.health = health
	
	slime_hit.play()
	flash_white()

	if health <= 0:
		queue_free()
		
func deal_damage(dmg: int) -> void:
	if can_deal_damage:
		player.take_damage(dmg)
		can_deal_damage = false
		damage_timer.start()

func play_animation(anim_name: String) -> void:
	animation_player.play(anim_name)

func flip_sprite(value: bool) -> void:
	animated_sprite.flip_h = value
	
func flip_gravity(value: bool) -> void:
	gravity_switch = value

func auto_flip_check():
	if velocity.x > 0:
		flip_sprite(false)
	elif velocity.x < 0:
		flip_sprite(true)

func _physics_process(delta: float) -> void:	
	auto_flip_check()
	
	if not is_on_floor() and gravity_switch:
		velocity += get_gravity() * delta
		
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_area = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_area = null

func _on_damage_timer_timeout() -> void:
	can_deal_damage = true
