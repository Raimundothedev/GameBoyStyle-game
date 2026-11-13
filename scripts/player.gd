extends CharacterBody2D
@onready var movement = $Movement
@onready var combat = $Combat
@onready var stats = $Stats
@onready var animated_sprite_2d = $AnimatedSprite2D

var attacking = false
var attacked = false

# DEBUG ------------------------------
var spells = ["fireball", "pickaxe"]
var current_index = 0
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_spells"):
		current_index += 1
		
		if current_index >= spells.size():
			current_index = 0
		
		stats.equipped_spell = spells[current_index]

func _physics_process(delta: float) -> void:
	movement.handle_gravity(delta)
	movement.handle_jump()
	movement.handle_movement(delta)
	movement.dash_skill()
	combat.cast_spell()
	stats.regen_mana()
	handle_animation()
	
	
	move_and_slide()
	
func handle_animation() -> void:
	if attacked:
		animated_sprite_2d.play("Hit")
		return
	if attacking:
		animated_sprite_2d.play("Attacking")
		return
	if not is_zero_approx(velocity.x):
		animated_sprite_2d.flip_h = velocity.x < 0
		animated_sprite_2d.play("Walking")
		return
	animated_sprite_2d.play("Idle")
		



	
		
	
