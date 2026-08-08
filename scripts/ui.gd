extends CanvasLayer

@onready var enemy_health_bar: ProgressBar = %EnemyHealthBar
@onready var player_health_bar: ProgressBar = %PlayerHealthBar

func _ready() -> void:
	Autoload.ui_node = self
	Autoload.slime_boss_node.health_changed.connect(_on_enemy_health_changed)
	Autoload.player_node.health_changed.connect(_on_player_health_changed)
	
	_on_player_health_changed(Autoload.player_node.health, Autoload.player_node.max_health)
	_on_enemy_health_changed(Autoload.slime_boss_node.health, Autoload.slime_boss_node.max_health)
	
func _on_enemy_health_changed(current: float, max: float) -> void:
	enemy_health_bar.max_value = max
	enemy_health_bar.damage_bar.max_value = max
	enemy_health_bar.health = current


func _on_player_health_changed(current: float, max: float) -> void:
	player_health_bar.max_value = max
	player_health_bar.damage_bar.max_value = max
	player_health_bar.health = current
