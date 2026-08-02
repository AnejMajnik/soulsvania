extends State

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var player: Player = owner
@onready var heavy_attack_area: Area2D = %HeavyAttackArea

@export var idle_state: State

const DAMAGE: int = 25

func enter_state() -> void:
	animation_player.play("heavy_attack")
	player.velocity.x = 0
	
func deal_damage_heavy():
	print("deal damage called")
	for body in heavy_attack_area.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			body.take_damage(DAMAGE)
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "heavy_attack":
		switch_state.emit(idle_state)
