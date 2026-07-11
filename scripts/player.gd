class_name Player extends CharacterBody2D

# Variables
@export var SPEED = 200.0
@export var DECCELERATION_SPEED = 20
@export var JUMP_VELOCITY = -275.0

@export var attack_state: State
@export var HEALTH = 100
@export var attack_combo_dmg = 10

var current_enemy: CharacterBody2D = null

# References
@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D
#@onready var enemy_cube: CharacterBody2D = $"../EnemyCube"
@onready var state_machine: StateMachine = $StateMachine

func get_hit(damage):
	HEALTH -= damage
	print("Player health: ", HEALTH)

func flip_sprite(direction) -> void:
	if direction > 0:
		animated_sprite.flip_h = false
		area_2d.position.x = abs(area_2d.position.x)
	elif direction < 0:
		animated_sprite.flip_h = true
		area_2d.position.x = -abs(area_2d.position.x)
		
func _ready() -> void:
	Autoload.player_node = self
	attack_state.hit.connect(_on_attack_hit)
	state_machine.start()

func _on_attack_hit():
	#enemy_cube.get_hit(attack_combo_dmg)
	pass
	
func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
	# Flip sprite based on direction
	flip_sprite(direction)
	
	if HEALTH <= 0:
		set_physics_process(false) #Stop processing
		get_tree().call_deferred("reload_current_scene")
		return #Exit before move_and_slide runs
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body != self:
		current_enemy = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body != self:
		current_enemy = null
