extends State

@onready var slime_boss: SlimeBoss = owner
@onready var player: Player = Autoload.player_node

@onready var laser_ray_cast: RayCast2D = %LaserRayCast
@onready var beam_shoot: AudioStreamPlayer2D = $Sounds/BeamShoot

enum Substate { TELEGRAPH, ATTACK }
var current_state: Substate

var player_pos_x
var player_pos_y

var recovery_time: float = 1.0

func enter_state() -> void:
	change_substate(Substate.TELEGRAPH)
	
func change_substate(new_state: Substate) -> void:
	if new_state != current_state:
		current_state = new_state
		
	match current_state:
		Substate.TELEGRAPH:
			slime_boss.play_animation("beam_telegraph")
		Substate.ATTACK:
			attack()

func physics_update(_delta: float) -> void:
	if current_state == Substate.ATTACK and laser_ray_cast.is_colliding():
		print("colliding")
		state_finished.emit(recovery_time)

func attack() -> void:
	beam_shoot.play()
	laser_ray_cast.start_cast(Vector2(player_pos_x, player_pos_y-20))

func get_player_pos():
	player_pos_x = player.global_position.x
	player_pos_y = player.global_position.y
