extends Node2D

func _ready() -> void:
	$UI.controls_requested.connect(_on_controls_requested)
	print("Viewport visible rect: ", get_viewport().get_visible_rect())
	print("Window size: ", DisplayServer.window_get_size())
	print("MarginContainer global position: ", $UI/Control/MarginContainer.global_position)
	print("MarginContainer size: ", $UI/Control/MarginContainer.size)
	print("Control size: ", $UI/Control.size)
	print("Control anchors: L", $UI/Control.anchor_left, " R", $UI/Control.anchor_right, " T", $UI/Control.anchor_top, " B", $UI/Control.anchor_bottom)
	
func _on_controls_requested():
	$ControlsPopup.open()
