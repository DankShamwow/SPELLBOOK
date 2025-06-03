extends Resource
class_name RunStats

signal gold_changed

const STARTING_GOLD := 100

@export var gold := STARTING_GOLD

func add_gold(gold_added: int) -> void:
	gold += gold_added
	gold_changed.emit()
	
