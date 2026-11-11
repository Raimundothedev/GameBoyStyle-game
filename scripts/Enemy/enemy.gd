extends CharacterBody2D
class_name Enemy

@export var hp: float = 100
@export var speed: float = 100
@export var dmg: float = 10
@export var knockback_multiplier: float = 1.0
@export var jump_velocity: float = -350
@export var attack_cooldown: float = 3
@export var dash_speed: float = 500.0
@export var dash_duration: float = 0.25


@onready var animated_sprite_2d = get_node_or_null("AnimatedSprite2D")

var player: CharacterBody2D
@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")	
	hitbox.body_entered.connect(_on_body_entered)
	for area in [$Range, $AttackRange]:
		area.body_entered.connect(_on_range_changed.bind(area, true))
		area.body_exited.connect(_on_range_changed.bind(area, false))
	
var player_on_range = false
var player_on_atkrange = false
var player_attack = false

func _on_range_changed(body: Node2D, area: Area2D, state: bool) -> void:
	if not body.is_in_group("player"):
		return
	
	if area == $Range:
		player_on_range = state
	elif area == $AttackRange:
		player_on_atkrange = state

var direction: Vector2

func chase_player(delta: float) -> void:
	if player == null:
		return
		
	if not player_on_range:
		if not player_attack:
			return
			
	if is_dashing or player_attack:
		return
			
	#if player_on_atkrange:
		#attack_anim()

	direction = (player.global_position - global_position).normalized()

	velocity.x = direction.x * speed
	
	
func handle_jump():
	if is_on_floor():
		velocity.y = jump_velocity
		return

var previous_position: Vector2

func _physics_process(delta: float) -> void:
	previous_position = global_position
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_floor() and is_on_wall():
		var collision = get_last_slide_collision()

		if collision and not collision.get_collider().is_in_group("player"):
			handle_jump()
	
	chase_player(delta)
	handle_animation()
	
	move_and_slide()
	
func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func take_damage(d: float, atker) -> void:
	player_attack = true
	hp -= d
	
	if hp <= 0:
		queue_free()
		
	var knockback_direction = (global_position - atker.global_position).normalized()
	velocity.x = knockback_direction.x * 100 * knockback_multiplier
	velocity.y = -350
	
	await get_tree().create_timer(0.5).timeout
	player_attack = false

var is_dashing: bool = false
var can_attack: bool = true
		
#func attack_anim() -> void:
	#if not direction:
		#return
		#
	#can_attack = false
	#is_dashing = true
#
	#velocity.x = 0
	#await get_tree().create_timer(0.5).timeout
	#
	#add_collision_exception_with(player)
	#direction = (player.global_position - global_position).normalized()
	#velocity.x = direction.x * dash_speed
	#
	#await get_tree().create_timer(dash_duration).timeout
	#
	#velocity.x = 0
	#is_dashing = false
	#remove_collision_exception_with(player)
	#
	#await get_tree().create_timer(attack_cooldown).timeout
	#can_attack = true
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(dmg, self)
		print("awdad")

func handle_animation():
	if not animated_sprite_2d:
		return
	
	var moving = not is_zero_approx(global_position.x - previous_position.x)
	
	if moving:
		animated_sprite_2d.flip_h = velocity.x < 0

		if animated_sprite_2d.sprite_frames.has_animation("walking"):
			animated_sprite_2d.play("walking")
	else:
		if animated_sprite_2d.sprite_frames.has_animation("idle"):
			animated_sprite_2d.play("idle")
	
