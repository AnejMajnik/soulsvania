extends RayCast2D

@export var cast_speed := 5000.0
@export var max_length := 1400.0
@export var is_casting := false: set = set_is_casting
@export var growth_time := 0.05

var tween: Tween = null
var target_global := Vector2.ZERO
var current_length := 0.0

@onready var line_2d: Line2D = $Line2D
@onready var line_width := line_2d.width
@onready var parent := get_parent()

signal player_hit
signal foreground_hit

func _physics_process(delta: float) -> void:
	current_length = move_toward(current_length, max_length, cast_speed * delta)

	var dir := to_local(target_global).normalized()
	target_position = dir * current_length

	var laser_end_position := target_position
	force_raycast_update()
	if is_colliding():
		laser_end_position = to_local(get_collision_point())
	
	var pts := line_2d.points
	pts[1] = laser_end_position
	line_2d.points = pts
	
	if is_colliding():
		var collider := get_collider()
		laser_end_position = to_local(get_collision_point())
		if collider.name == "Player":
			emit_signal("player_hit")
		else:
			emit_signal("foreground_hit")
		end_cast()
		return

func start_cast(global_target: Vector2) -> void:
	target_global = global_target
	current_length = 0.0
	is_casting = true

func end_cast() -> void:
	is_casting = false

func set_is_casting(new_value: bool) -> void:
	if is_casting == new_value:
		return
	is_casting = new_value

	set_physics_process(is_casting)

	if not line_2d:
		return

	if is_casting == false:
		current_length = 0.0
		dissapear()
	else:
		appear()

func _ready() -> void:
	line_2d.visible = false
	line_2d.width = 0.0
	set_physics_process(false)

func appear() -> void:
	line_2d.visible = true
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(line_2d, "width", line_width, growth_time * 2.0).from(0.0)

func dissapear() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(line_2d, "width", 0.0, growth_time).from_current()
	tween.tween_callback(line_2d.hide)
