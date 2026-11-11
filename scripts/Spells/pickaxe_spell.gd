extends Spell
@export var affected_by_gravity: bool = true
@export var _gravity: float = 980

var vertical_velocity: float = 0.0

func move_spell(delta: float) -> void:
	global_position += direction * vel * delta
	vertical_velocity += _gravity * delta
	global_position.y += vertical_velocity * delta
