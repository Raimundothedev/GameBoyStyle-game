extends Control

@onready var health_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var mana_bar: ProgressBar = $VBoxContainer/ProgressBar2
@onready var player: CharacterBody2D = $"../../LevelRoot/Player"


func _ready() -> void:
	player.health_changed.connect(update_health)
	player.mana_changed.connect(update_mana)
	
	update_health(player.hp)
	update_mana(player.mana)
	
	
func update_health(value: float) -> void:
	health_bar.value = value
	
func update_mana(value: float) -> void:
	mana_bar.value = value
