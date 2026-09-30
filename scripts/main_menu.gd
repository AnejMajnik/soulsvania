extends Node2D

func _ready() -> void:
	%"Slime Boss".grab_focus()

func _on_slime_boss_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/boss_fight_1.tscn")


func _on_reaper_boss_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/boss_fight_2.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")
