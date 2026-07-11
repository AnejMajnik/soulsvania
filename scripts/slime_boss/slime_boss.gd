class_name SlimeBoss extends CharacterBody2D

# Constants
const MOVE_SPEED = 200.0
const DECCELERATION_SPEED = 15
const JUMP_VELOCITY = -600.0
const DASH_SPEED = 650
const SLAM_SPEED = 475
const FLY_SPEED = 300

var max_health: int = 200
var health: int = max_health
var next_recovery_time: float

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

func auto_flip_check():
	if velocity.x > 0:
		flip_sprite(false)
	elif velocity.x < 0:
		flip_sprite(true)

func _physics_process(delta: float) -> void:	
	auto_flip_check()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()
