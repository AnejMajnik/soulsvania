extends CharacterBody2D

# Enum
enum State { CHASE, TELEGRAPH, ATTACK, RECOVER }

# Constants
const SPEED = 100.0
const DECCELERATION_SPEED = 20
const JUMP_VELOCITY = -250.0

# Variables
var current_state: State = State.CHASE
var health = 100
var telegraphing = false
var attacking = false
var player_pos_x = 0
var player_pos_y = 0
var attack_time = 1
var recovering = false

# References
@onready var player: CharacterBody2D = %Player
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

func get_player_pos():
	player_pos_x = player.global_position.x
	player_pos_y = player.global_position.y
	

func chase_player():
	animated_sprite.play("idle")
	
	if global_position.distance_to(player.global_position) < 150 and !telegraphing:
		current_state = State.TELEGRAPH
	
	var direction
	if sign(player.global_position.x - global_position.x) > 0:
		direction = 1
	else:
		direction = -1
		
	velocity.x = SPEED * direction
	
func telegraph_attack():
	telegraphing = true
	animated_sprite.play("telegraph")
	velocity.x = 0
	
func attack():
	velocity.x = (player_pos_x - global_position.x) / attack_time
	velocity.y = (player_pos_y - global_position.y - 0.5 * get_gravity().y * attack_time * attack_time) / attack_time


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match current_state:
		State.CHASE:
			chase_player()	
		State.TELEGRAPH:
			telegraph_attack()
		State.ATTACK:
			if !attacking:
				attack()
				print("start: ", global_position.x)
				print("target_x: ", player.global_position.x)
				print("velocity.x: ", velocity.x)
				attacking = true
			if is_on_floor() and velocity.y >= 0:
				print("after: ", global_position.x)
				attacking = false
				current_state = State.RECOVER
		State.RECOVER:
			if !recovering:
				timer.start()
				recovering = true

	if is_on_floor() and current_state != State.ATTACK:
		velocity.x = move_toward(velocity.x, 0, DECCELERATION_SPEED)
	
	move_and_slide()


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "telegraph":
		get_player_pos()
		telegraphing = false
		current_state = State.ATTACK


func _on_timer_timeout() -> void:
	print("Timer timeout reached")
	current_state = State.CHASE
	recovering = false
