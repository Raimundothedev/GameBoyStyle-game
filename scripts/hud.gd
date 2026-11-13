extends Control

@onready var health_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var mana_bar: ProgressBar = $VBoxContainer/ProgressBar2
@onready var player: CharacterBody2D = $"../../LevelRoot/Player"
@onready var player_stats: Node = player.get_node("Stats")


func _ready() -> void:
	player_stats.health_changed.connect(update_health)
	player_stats.mana_changed.connect(update_mana)
	
	update_health(player_stats.hp)
	update_mana(player_stats.mana)
	
	
func update_health(value: float) -> void:
	health_bar.value = value
	
func update_mana(value: float) -> void:
	mana_bar.value = value
