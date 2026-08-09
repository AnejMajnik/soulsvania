extends State

# States
@export var chase_state: State

# Character references
@onready var slime_boss: SlimeBoss = owner
@onready var player: Player = Autoload.player_node

@onready var growl: AudioStreamPlayer2D = $Growl
@onready var music: AudioStreamPlayer2D = %Music

func enter_state() -> void:
	slime_boss.play_animation("idle")
	growl.play()
	
func physics_update(_delta: float) -> void:
	if slime_boss.global_position.distance_to(player.global_position) < 450:
		switch_state.emit(chase_state)

func exit_state() -> void:
	var tween = create_tween()
	tween.tween_property(growl, "volume_db", -40.0, 0.5) # fade out
	tween.tween_callback(growl.stop)
	music.play()

func _on_growl_finished() -> void:
	growl.play()
