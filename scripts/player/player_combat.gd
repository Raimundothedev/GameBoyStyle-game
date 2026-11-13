extends Node

@onready var player = get_parent()
@onready var stats = player.get_node("Stats")
@onready var movement = player.get_node("Movement")

func cast_spell() -> void:
	var is_pressed = Input.is_action_just_pressed("spell_skill")
	if is_pressed:
		if player.attacking or not stats.equipped_spell or player.attacked:
			return 
		var spell_scene = SpellDB.get_spell(stats.equipped_spell)
		var spell = spell_scene.instantiate()
		
		if spell.mana_cost > stats.mana:
			return 
			
		player.attacking = true
		spell.setup(player, stats.mana)
		stats.spend_mana(spell.mana_cost)
		
		get_tree().current_scene.add_child(spell)
		if movement.last_direction[0] > 0:
			spell.global_position = player.global_position + Vector2(60, 0)
		else:
			spell.global_position = player.global_position + Vector2(-60, 0)
		spell.direction = movement.last_direction
		
		await get_tree().create_timer(0.5).timeout
		player.attacking = false
		return 
	
	return 
