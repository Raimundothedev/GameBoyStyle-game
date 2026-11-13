extends Node

@onready var player = get_parent()
@onready var stats = player.get_node("Stats")
@onready var effect1_scene = preload("res://scenes/multiple_jump_effect.tscn")

var direction: Vector2 = Vector2.ZERO
var last_direction := Vector2.RIGHT
var can_dash: bool = true
var jump_count: int

func _ready() -> void:
	jump_count = stats.max_jumps

func handle_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
	if player.attacked:
		return
	
	if direction:
		last_direction = Vector2(direction, 0)
		player.velocity.x = move_toward(
			player.velocity.x,
			direction * stats.speed,
			stats.acceleration * delta
		)
		return
	player.velocity.x = move_toward(
		player.velocity.x,
		0.0,
		stats.friction * delta
	)
	return

func handle_gravity(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
	if player.is_on_floor():
		jump_count = stats.max_jumps
		
func handle_jump():
	if player.attacked:
		return
	
	if Input.is_action_just_pressed("move_up"):
		if player.is_on_floor():
			player.velocity.y = stats.jump_velocity
			return
		multiple_jumps()
		
func multiple_jumps():
	if player.attacked:
		return
	
	if jump_count <= 0:
			return
	jump_count -= 1
	player.velocity.y = stats.jump_velocity * stats.jump_amplifier
	for i in range(randi_range(1, 5)):
		var mult_jump_effect = effect1_scene.instantiate()
		get_tree().current_scene.add_child(mult_jump_effect)
		mult_jump_effect.global_position = player.global_position + Vector2(
			randi_range(-20, 20),
			randi_range(-20, 20)
		)

func dash_skill():
	if not can_dash:
		return
	if Input.is_action_just_pressed("dash_skill"):
		player.velocity.x += last_direction.x * stats.dash_velocity
		can_dash = false
		await get_tree().create_timer(stats.dash_cooldown).timeout
		can_dash = true
