extends CharacterBody2D

# Constants
const SPEED = 200.0
const DECCELERATION_SPEED = 20
const JUMP_VELOCITY = -300.0

# Variables
var is_attacking = false;
var is_jumping = false;

# References
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func start_attack_combo():
	interrupt_jump();
	is_attacking = true
	animated_sprite.play("attack_combo")
	
func interrupt_attack():
	if is_attacking:
		is_attacking = false;
	
func start_jump():
	interrupt_attack()
	is_jumping = true;
	animated_sprite.play("jump")
	velocity.y = JUMP_VELOCITY

func interrupt_jump():
	if is_jumping:
		is_jumping = false

func read_inputs():
	# Look for jump animation
	if Input.is_action_just_pressed("jump") and is_on_floor() and !is_jumping:
		start_jump()
		
	# Get attack animation
	if Input.is_action_just_pressed("attack_combo") and !is_attacking:
		start_attack_combo()
		
	# Get input direction
	var direction := Input.get_axis("move_left", "move_right")
	
	# Flip the sprite
	if direction > 0 and !is_attacking:
		animated_sprite.flip_h = false
	elif direction < 0 and !is_attacking:
		animated_sprite.flip_h = true
	
	# Play animations
	if is_on_floor() and velocity.y >= 0:
		is_jumping = false
		if direction == 0 and !is_attacking:
			animated_sprite.play("idle")
		elif direction != 0 and !is_attacking:
			animated_sprite.play("run")
	elif is_jumping:
		animated_sprite.play("jump")
		
	# Move
	if direction and !is_attacking:
		velocity.x = direction * SPEED
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, DECCELERATION_SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, DECCELERATION_SPEED/4)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	read_inputs()

	move_and_slide()


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack_combo":
		is_attacking = false
