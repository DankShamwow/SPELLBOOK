extends GameEntity
class_name Character

signal update_buffered_tiles()

func on_turn_end():
	super()

func on_turn_start():
	update_buffered_tiles.emit()
	super()
