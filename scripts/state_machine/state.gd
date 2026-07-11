class_name State extends Node

signal switch_state(state: State)
signal state_finished(recovery_time: float)

func enter_state() -> void:
	pass
	
func exit_state() -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass
