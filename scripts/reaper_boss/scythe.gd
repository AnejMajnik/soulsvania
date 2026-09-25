extends Node2D

@onready var player: Player = Autoload.player_node
@onready var boss = Autoload.boss_node
@onready var scythe_area_2d: Area2D = $ScytheArea2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var direction = 0
const SPEED = 300
const DAMAGE = 10
var velocity: Vector2

var animation_started = false
var rotation_amount = PI/2
var starting_location
var is_returning = false

func _ready() -> void:
	animation_player.play("default")
	direction = sign(player.global_position.x - global_position.x)
	velocity.x = direction * SPEED
	starting_location = global_position.x
	
	if direction == -1:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false

func rotate_area() -> void:
	if !animation_started:
		animation_started = true
		return
		
	scythe_area_2d.rotate(rotation_amount)

func deal_damage():
	for body in scythe_area_2d.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(DAMAGE)

func _physics_process(delta: float) -> void:
	position.x += velocity.x * delta
	
	if abs(global_position.x - starting_location) > 300:
		is_returning = true
		velocity.x = move_toward(velocity.x, -direction * SPEED, 10)
		
	if is_returning and abs(global_position.x - boss.global_position.x) < 20:
		boss.play_animation("attack_projectile_wind_down")
		queue_free()
