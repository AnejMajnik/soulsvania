extends Node2D

@onready var resolution_dropdown: OptionButton = $CanvasLayer/Control/ResolutionDropdown
@onready var full_screen_dropdown: OptionButton = $CanvasLayer/Control/FullScreenDropdown

@onready var win: Window = get_window()

@onready var _sfx_bus := AudioServer.get_bus_index("SFX")
@onready var _music_bus := AudioServer.get_bus_index("Music")
@onready var sfx_slider: HSlider = $"CanvasLayer/Control/SFX Slider"
@onready var music_slider: HSlider = $"CanvasLayer/Control/Music Slider"

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
		
	resolution_dropdown.grab_focus()
	
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(_sfx_bus))
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(_music_bus))

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


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_sfx_bus, linear_to_db(value))


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(_music_bus, linear_to_db(value))
