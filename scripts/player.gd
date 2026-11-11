extends CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var mult_jump_scene = preload("res://scenes/multiple_jump_effect.tscn")

@export var max_hp: float = 100
var hp: float = max_hp
@export var max_mana: float = 100
var mana: float = max_mana
@export var dmg: float = 50
@export var speed: float = 300.0
@export var acceleration: float = 1200.0
@export var friction: float = 1200.0
@export var max_jumps: int = 1
@export var jump_amplifier: float = 1.2
@export var jump_velocity: float = -400
@export var dash_velocity: float = 500
@export var dash_cooldown: float = 5
@export_enum("fireball", "pickaxe", "lighting") var equipped_spell: String

var direction: Vector2 = Vector2.ZERO
var last_direction := Vector2.RIGHT
var jump_counts: int = max_jumps
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
		
		equipped_spell = spells[current_index]
		
		

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_jump()
	handle_animation()
	handle_movement(delta)
	dash_skill()
	handle_attack()
	
	move_and_slide()
	
func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_on_floor():
		jump_counts = max_jumps
		
func handle_jump():
	if attacked:
		return
	
	if Input.is_action_just_pressed("move_up"):
		if is_on_floor():
			velocity.y = jump_velocity
			return
		multiple_jumps()
		
func multiple_jumps():
	if attacked:
		return
	
	if jump_counts <= 0:
			return
	jump_counts -= 1
	velocity.y = jump_velocity * jump_amplifier
	for i in range(randi_range(1, 5)):
		var mult_jump_effect = mult_jump_scene.instantiate()
		get_tree().current_scene.add_child(mult_jump_effect)
		mult_jump_effect.global_position = global_position + Vector2(
			randi_range(-20, 20),
			randi_range(-20, 20)
		)						
	
func handle_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
	if attacked:
		return
	
	if direction:
		last_direction = Vector2(direction, 0)
		velocity.x = move_toward(
			velocity.x,
			direction * speed,
			acceleration * delta
		)
		return
	velocity.x = move_toward(
		velocity.x,
		0.0,
		friction * delta
	)
	return
	
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
		
signal health_changed(value)
signal mana_changed(value)

func handle_attack() -> void:
	var is_pressed = Input.is_action_just_pressed("spell_skill")
	if is_pressed:
		if attacking or not equipped_spell or attacked:
			return 
		var spell_scene = SpellDB.get_spell(equipped_spell)
		var spell = spell_scene.instantiate()
		
		print(spell.mana_cost)
		if spell.mana_cost > mana:
			return 
		attacking = true
		spell.setup(self, mana)
		mana -= spell.mana_cost
		mana_changed.emit(mana)
		
		get_tree().current_scene.add_child(spell)
		if last_direction[0] > 0:
			spell.global_position = global_position + Vector2(60, 0)
		else:
			spell.global_position = global_position + Vector2(-60, 0)
		spell.direction = last_direction
		
		await get_tree().create_timer(0.5).timeout
		attacking = false
		return 
	
	return 
	
func take_damage(d: float, enemy: Node2D):
	hp -= d
	health_changed.emit(hp)
	
	if hp <= 0:
		print("Game Over baby")
	
	attacked = true
	var knockback_direction = (global_position - enemy.global_position).normalized()
	velocity.x = knockback_direction.x * 500
	velocity.y = -350
	
	await get_tree().create_timer(0.5).timeout
	attacked = false
	
var can_dash = true

func dash_skill():
	if not can_dash:
		return
	if Input.is_action_just_pressed("dash_skill"):
		print("aura")
		velocity.x += last_direction.x * dash_velocity
		can_dash = false
		await get_tree().create_timer(dash_cooldown).timeout
		can_dash = true


	
		
	
