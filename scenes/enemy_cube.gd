extends CharacterBody2D

# Enum
enum State { CHASE, TELEGRAPH, ATTACK, RECOVER }
enum Attacks { JUMP, DASH }

# Constants
const SPEED = 200.0
const DECCELERATION_SPEED = 15
const JUMP_VELOCITY = -280.0
const DASH_SPEED = 650

# Variables
var current_state: State = State.CHASE
var health = 100
var damage = 50
var telegraphing = false
var attacking = false
var can_deal_damage = true
var player_pos_x = 0
var player_pos_y = 0
var attack_time = 0.85
var recovering = false
var current_enemy: CharacterBody2D = null
var attack_type: Attacks

# References
@onready var player: CharacterBody2D = %Player
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer: Timer = $AttackTimer
@onready var deal_damage_timer: Timer = $DealDamageTimer
@onready var area_2d: Area2D = $Area2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_down_left: RayCast2D = $RayCastDownLeft
@onready var ray_cast_down_right: RayCast2D = $RayCastDownRight

func choose_attack() -> Attacks:
	var rand_val = randf()
	
	if ray_cast_left.is_colliding() or ray_cast_right.is_colliding():
		return Attacks.JUMP
		
	if rand_val <= 0.5:
		return Attacks.JUMP
	else:
		return Attacks.DASH

func get_player_pos():
	player_pos_x = player.global_position.x
	player_pos_y = player.global_position.y
	

func chase_player():
	animated_sprite.play("move")
	
	if global_position.distance_to(player.global_position) < 200 and !telegraphing:
		current_state = State.TELEGRAPH
	
	var direction
	if sign(player.global_position.x - global_position.x) > 0:
		direction = 1
		animated_sprite.flip_h = false
	else:
		direction = -1
		animated_sprite.flip_h = true
		
	velocity.x = SPEED * direction
	
func telegraph_attack():
	telegraphing = true
	attack_type = choose_attack()
	
	if attack_type == Attacks.JUMP:
		animated_sprite.play("telegraph_jump")
	elif attack_type == Attacks.DASH:
		animated_sprite.play("telegraph_dash")
	
	velocity.x = 0
	
func jump_attack():
	animated_sprite.play("attack_jump")
	
	velocity.x = (player_pos_x - global_position.x) / attack_time
	velocity.y = (player_pos_y - global_position.y - 0.5 * get_gravity().y * attack_time * attack_time) / attack_time

func dash_attack():
	animated_sprite.play("attack_dash")
	
	var direction
	if sign(player.global_position.x - global_position.x) > 0:
		direction = 1
		animated_sprite.flip_h = false
	else:
		direction = -1
		animated_sprite.flip_h = true
		
	velocity.x = direction * DASH_SPEED

func get_hit(hit_damage):
	health -= hit_damage
	print(health)

func _physics_process(delta: float) -> void:
	if health <= 0:
		queue_free()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		if (ray_cast_down_left.is_colliding() or ray_cast_down_right.is_colliding()) and velocity.y > 50:
			animated_sprite.play("land")
		
	if current_enemy == player and can_deal_damage:
		player.get_hit(damage)
		deal_damage_timer.start()
		can_deal_damage = false
	
	match current_state:
		State.CHASE:
			chase_player()	
		State.TELEGRAPH:
			if !telegraphing:
				telegraph_attack()
		State.ATTACK:
			if !attacking:
				match attack_type:
					Attacks.JUMP:
						jump_attack()
						attacking = true
					Attacks.DASH:
						dash_attack()
						attacking = true
						
			if is_on_floor() and velocity.y >= 0 and attack_type == Attacks.JUMP:
				attacking = false
				current_state = State.RECOVER
				
			if attack_type == Attacks.DASH:
				if ray_cast_left.is_colliding() or ray_cast_right.is_colliding():
					attacking = false
					current_state = State.RECOVER
					
		State.RECOVER:
			if !recovering:
				animated_sprite.play("recover")
				attack_timer.start()
				recovering = true

	if is_on_floor() and current_state != State.ATTACK:
		velocity.x = move_toward(velocity.x, 0, DECCELERATION_SPEED)
	
	move_and_slide()


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "telegraph_jump":
		get_player_pos()
		telegraphing = false
		current_state = State.ATTACK
	elif animated_sprite.animation == "telegraph_dash":
		get_player_pos()
		telegraphing = false
		current_state = State.ATTACK


func _on_attack_timer_timeout() -> void:
	current_state = State.CHASE
	recovering = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body != self:
		current_enemy = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body != self:
		current_enemy = null

func _on_deal_damage_timer_timeout() -> void:
	can_deal_damage = true
