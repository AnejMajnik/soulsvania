extends Node2D

@onready var resolution_dropdown: OptionButton = $CanvasLayer/Control/ResolutionDropdown
@onready var full_screen_dropdown: OptionButton = $CanvasLayer/Control/FullScreenDropdown

@onready var win: Window = get_window()

const RESOLUTIONS = [
	Vector2i(3440, 1440),
	Vector2i(2560, 1440),
	Vector2i(1920, 1080)
]

const FULLSCREEN_OPTIONS = [
	"Windowed",
	"Fullscreen"
]

func _ready() -> void:
	for res in RESOLUTIONS:
		resolution_dropdown.add_item(str(res.x) + " x " + str(res.y))
		
	for opt in FULLSCREEN_OPTIONS:
		full_screen_dropdown.add_item(opt)
	

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_resolution_dropdown_item_selected(index: int) -> void:
	win.mode = Window.MODE_WINDOWED
	win.size = RESOLUTIONS[index]
	win.move_to_center()


func _on_full_screen_dropdown_item_selected(index: int) -> void:
	if FULLSCREEN_OPTIONS[index] == "Windowed":
		win.mode = Window.MODE_WINDOWED
	else:
		win.mode = Window.MODE_FULLSCREEN
