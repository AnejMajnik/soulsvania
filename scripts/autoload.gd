extends Node

var player_node = null
var boss_node = null
var ui_node = null
var ground_reference = null

func freeze_frame_short():
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.05, true, false, true).timeout
	Engine.time_scale = 1.0
	
func freeze_frame_long():
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.2, true, false, true).timeout
	Engine.time_scale = 1.0
	
