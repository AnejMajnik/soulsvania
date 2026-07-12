class_name SlimeBoss extends CharacterBody2D

# Constants
const MOVE_SPEED = 200.0
const DECCELERATION_SPEED = 15
const DASH_SPEED = 650
const SLAM_SPEED = 600
const FLY_SPEED = 300

var max_health: int = 200
var health: int = max_health
var next_recovery_time: float
var gravity_switch: bool = true

@onready var player: Player = Autoload.player_node
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine

func _ready() -> void:
	state_machine.start()

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
