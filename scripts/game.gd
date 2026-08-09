extends Node2D

func _ready() -> void:
	$UI.controls_requested.connect(_on_controls_requested)
	
func _on_controls_requested():
	$ControlsPopup.open()
