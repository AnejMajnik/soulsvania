extends PopupPanel

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	popup_hide.connect(_on_popup_hide)

func _on_popup_hide():
	get_tree().paused = false

func open():
	get_tree().paused = true
	popup_centered(Vector2(600, 250))

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		hide()
