extends RefCounted
class_name Blackboard

var data: Dictionary = {}

func set_value(key: String, value) -> void:
	data[key] = value
	
func get_value(key: String, default = null):
	return data.get(key, default)
	
func has_value(key: String) -> bool:
	return data.has(key)
