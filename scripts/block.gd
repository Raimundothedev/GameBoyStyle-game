extends StaticBody2D
class_name Block

@export var breakable: bool = false	
@export var block_level: int = 1
	
func destroy(break_level):
	if breakable:
		if break_level < self.block_level:
			return
		queue_free()
