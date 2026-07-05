extends CharacterBody2D

# Constants
const SPEED = 200.0
const DECCELERATION_SPEED = 20
const JUMP_VELOCITY = -275.0

# Variables
var is_attacking = false;
var is_jumping = false;
var has_double_jumped = false;
var health = 100
var attack_combo_dmg = 10
var current_enemy: CharacterBody2D = null

# References
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D
@onready var enemy_cube: CharacterBody2D = $"../EnemyCube"

func get_hit(damage):
	health -= damage
	print("Player health: ", health)

func start_attack_combo():
	interrupt_jump();
	is_attacking = true
	animated_sprite.play("attack_combo")
	
func interrupt_attack():
	if is_attacking:
		is_attacking = false;
	
func start_jump():
	if !is_on_floor():
		has_double_jumped = true
	
	interrupt_attack()
	is_jumping = true;
	animated_sprite.play("jump")
	velocity.y = JUMP_VELOCITY

func interrupt_jump():
	if is_jumping:
		is_jumping = false

func read_inputs():
	# Look for jump animation
	if Input.is_action_just_pressed("jump") and !has_double_jumped:
		start_jump()
		
	# Get attack animation
	if Input.is_action_just_pressed("attack_combo") and !is_attacking:
		start_attack_combo()
		
	# Get input direction
	var direction := Input.get_axis("move_left", "move_right")
	
	# Flip the sprite
	if direction > 0 and !is_attacking:
		animated_sprite.flip_h = false
		area_2d.position.x = abs(area_2d.position.x)
	elif direction < 0 and !is_attacking:
		animated_sprite.flip_h = true
		area_2d.position.x = -abs(area_2d.position.x)
	
	# Play animations
	if is_on_floor() and velocity.y >= 0:
		is_jumping = false
		has_double_jumped = false
		
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

func _physics_process(delta: float) -> void:
	if health <= 0:
		set_physics_process(false) #Stop processing
		get_tree().call_deferred("reload_current_scene")
		return #Exit before move_and_slide runs
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	read_inputs()

	move_and_slide()


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack_combo":
		is_attacking = false


func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite and animated_sprite.animation == "attack_combo":
		if animated_sprite.frame in [4, 8]:
			if current_enemy != null and current_enemy == enemy_cube:
				enemy_cube.get_hit(attack_combo_dmg)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body != self:
		current_enemy = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body != self:
		current_enemy = null
