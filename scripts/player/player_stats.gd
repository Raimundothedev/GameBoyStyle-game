extends Node

signal health_changed(hp)
signal mana_changed(mana)

@onready var player = get_parent()

# Base Atributes
@export var max_hp: float = 100
@export var max_mana: float = 100
@export var mana_regen_mult: float = 1
@export var dmg: float = 50
@export var speed: float = 300.0
@export var max_jumps: int = 1

var hp: float = max_hp
var mana: float = max_mana

# Moviment variables
@export var acceleration: float = 1200.0
@export var friction: float = 1200.0
@export var jump_amplifier: float = 1.2
@export var jump_velocity: float = -400
@export var dash_velocity: float = 500
@export var dash_cooldown: float = 5

# Spells
@export_enum("fireball", "pickaxe", "lighting") var equipped_spell: String

func take_damage(d: float, enemy: Node2D):
	hp -= d
	health_changed.emit(hp)
	
	if hp <= 0:
		print("Game Over baby")
	
	player.attacked = true
	var knockback_direction = (player.global_position - enemy.global_position).normalized()
	player.velocity.x = knockback_direction.x * 500
	player.velocity.y = -350
	
	await get_tree().create_timer(0.5).timeout
	player.attacked = false
	
func heal(amount: int):
	hp = min(max_hp, hp + amount)
	health_changed.emit(hp)
	
func spend_mana(amount: int) -> bool:
	if mana < amount:
		return false
	
	mana -= amount
	mana_changed.emit(mana)
	return true
	
var mana_regen: int
var can_regen: bool = true

func regen_mana():
	mana_regen = (max_mana / 100) * mana_regen_mult
	if not player.attacked:
		if can_regen and mana < max_mana:
			can_regen = false
			mana += mana_regen
			mana_changed.emit(mana)
			await get_tree().create_timer(1).timeout
			can_regen = true	
	
