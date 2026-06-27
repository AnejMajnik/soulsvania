extends CharacterBody2D

# Enum
enum State { CHASE, TELEGRAPH, ATTACK, RECOVER }
enum Attacks { JUMP, DASH }

# Constants
const SPEED = 100.0
const DECCELERATION_SPEED = 20
const JUMP_VELOCITY = -280.0
const DASH_SPEED = 600

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

func choose_attack() -> Attacks:
	var rand_val = randf()
	if rand_val <= 0.5:
		return Attacks.JUMP
	else:
		return Attacks.DASH

func get_player_pos():
	player_pos_x = player.global_position.x
	player_pos_y = player.global_position.y
	

func chase_player():
	animated_sprite.play("idle")
	
	if global_position.distance_to(player.global_position) < 200 and !telegraphing:
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
	
func jump_attack():
	velocity.x = (player_pos_x - global_position.x) / attack_time
	velocity.y = (player_pos_y - global_position.y - 0.5 * get_gravity().y * attack_time * attack_time) / attack_time

func dash_attack():
	var direction
	if sign(player.global_position.x - global_position.x) > 0:
		direction = 1
	else:
		direction = -1
		
	velocity.x = direction * DASH_SPEED

func get_hit(hit_damage):
	health -= hit_damage
	print(health)

func _physics_process(delta: float) -> void:
	if health <= 0:
		queue_free()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if current_enemy == player and can_deal_damage:
		player.get_hit(damage)
		deal_damage_timer.start()
		can_deal_damage = false
	
	match current_state:
		State.CHASE:
			chase_player()	
		State.TELEGRAPH:
			telegraph_attack()
		State.ATTACK:
			if !attacking:
				attack_type = choose_attack()
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
				attack_timer.start()
				recovering = true

	if is_on_floor() and current_state != State.ATTACK:
		velocity.x = move_toward(velocity.x, 0, DECCELERATION_SPEED)
	
	move_and_slide()


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "telegraph":
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
