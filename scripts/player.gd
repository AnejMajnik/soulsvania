extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -300.0

var is_attacking = false;

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func read_inputs():
	# Look for jump animation
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Get attack animation
	if Input.is_action_just_pressed("attack_combo") and !is_attacking:
		is_attacking = true
		animated_sprite.play("attack_combo")
		
	# Get input direction
	var direction := Input.get_axis("move_left", "move_right")
	
	# Flip the sprite
	if direction > 0 and !is_attacking:
		animated_sprite.flip_h = false
	elif direction < 0 and !is_attacking:
		animated_sprite.flip_h = true
		
	# Play animations
	if is_on_floor():
		if direction == 0 and !is_attacking:
			animated_sprite.play("idle")
		elif direction != 0 and !is_attacking:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
		
	# Move
	if direction and !is_attacking:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	read_inputs()

	move_and_slide()


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack_combo":
		is_attacking = false
