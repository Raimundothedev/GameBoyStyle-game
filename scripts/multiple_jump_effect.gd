extends Node2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.rotation += randf_range(0, TAU)
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.1, 1.1), 0.3)
	tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.3)

	await tween.finished
	queue_free()
