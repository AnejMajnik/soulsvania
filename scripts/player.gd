class_name Player extends CharacterBody2D

# Variables
@export var SPEED = 200.0
@export var DECCELERATION_SPEED = 20
@export var JUMP_VELOCITY = -275.0

@export var combo_hit_1: State
@export var combo_recover: State
@export var combo_hit_2: State
@export var heavy_attack: State

@export var max_health: int = 100
@export var health: int

var current_enemy: CharacterBody2D = null
var gravity_switch: bool = true
var invulnerable: bool = false
var current_speed = SPEED

# References
@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var hit_1_area: Area2D = %Hit1Area
@onready var hit_2_area: Area2D = $Hit2Area
@onready var heavy_attack_area: Area2D = %HeavyAttackArea
@onready var state_machine: StateMachine = $StateMachine
@onready var slime_boss: SlimeBoss = %SlimeBoss
@onready var player_hit: AudioStreamPlayer2D = $Sounds/PlayerHit
@onready var animation_player: AnimationPlayer = %AnimationPlayer

# Cooldowns
var dash_available: bool = true
@onready var dash_cooldown: Timer = %DashCooldown

# Slow down
@onready var slow_down_timer: Timer = %SlowDownTimer

signal health_changed(current: float, max: float)

func _ready() -> void:
	Autoload.player_node = self
	
	# Set up shader texture
	animated_sprite.material = ShaderMaterial.new()
	animated_sprite.material.shader = preload("res://shaders/player/flash.gdshader")
	
	# Set up health
	health = max_health
	
	state_machine.start()

func flip_invulnerable(value: bool) -> void:
	invulnerable = value
	
func slow_down() -> void:
	current_speed = SPEED/2
	if animation_player.current_animation == "run":
		animation_player.speed_scale = 0.5
		
	slow_down_timer.start()

func start_dash_cooldown() -> void:
	dash_available = false
	dash_cooldown.start()

func flash_take_damage() -> void:
	animated_sprite.material.set_shader_parameter("flash_color", Color(1.0, 1.0, 1.0, 1.0))
	var tween = create_tween()
	tween.tween_method(_set_flash, 1.0, 0.0, 0.2)
	
func flash_dash_available() -> void:
	animated_sprite.material.set_shader_parameter("flash_color", Color(0.006, 0.941, 0.991, 1.0))
	animated_sprite.material.set_shader_parameter("flash_opacity", 0.5)
	var tween = create_tween()
	tween.tween_method(_set_flash, 1.0, 0.0, 0.5)
	
func _set_flash(value: float) -> void:
	animated_sprite.material.set_shader_parameter("flash_amount", value)

func flip_gravity(value: bool) -> void:
	gravity_switch = value

func take_damage(damage):
	if !invulnerable:
		health -= damage
		health_changed.emit(health, max_health)
		
		player_hit.play()
		
		flash_take_damage()

func get_current_direction() -> int:
	if animated_sprite.flip_h == true:
		return -1
	else:
		return 1

func flip_sprite(direction) -> void:
	if direction > 0:
		animated_sprite.flip_h = false
		hit_1_area.position.x = abs(hit_1_area.position.x)
		hit_2_area.position.x = abs(hit_2_area.position.x)
		heavy_attack_area.position.x = abs(heavy_attack_area.position.x)
		hit_1_area.scale.x = 1
		hit_2_area.scale.x = 1
		heavy_attack_area.scale.x = 1
		
	elif direction < 0:
		animated_sprite.flip_h = true
		hit_1_area.position.x = -abs(hit_1_area.position.x)
		hit_2_area.position.x = -abs(hit_2_area.position.x)
		heavy_attack_area.position.x = -abs(heavy_attack_area.position.x)
		hit_1_area.scale.x = -1
		hit_2_area.scale.x = -1
		heavy_attack_area.scale.x = -1

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
	# Flip sprite based on direction
	if not state_machine.active_state.is_in_group("player_attack"):
		flip_sprite(direction)
	
	if health <= 0:
		set_physics_process(false) #Stop processing
		get_tree().call_deferred("reload_current_scene")
		return #Exit before move_and_slide runs
	
	# Add the gravity.
	if not is_on_floor() and gravity_switch:
		velocity += get_gravity() * delta

	move_and_slide()

func _on_dash_cooldown_timeout() -> void:
	dash_available = true
	flash_dash_available()

func _on_combo_attack_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body != self:
		current_enemy = body

func _on_combo_attack_area_2d_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body != self:
		current_enemy = null


func _on_slow_down_timer_timeout() -> void:
	current_speed = SPEED
	animation_player.speed_scale = 1.0
