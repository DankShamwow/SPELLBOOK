extends GameEntity
class_name Character

signal update_buffered_tiles()

@export_group("Gameplay Data")
@export var starting_deck = StartingTiles.StartingTileArray
@export var word_list = GeneralManager.word_list


func on_turn_end(_count):
	super(_count)

func on_turn_start(_count):
	GameEventHandler.update_buffered_tiles.emit()
	super(_count)
