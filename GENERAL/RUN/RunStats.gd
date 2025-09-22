extends Resource
class_name RunStats

const STARTING_GOLD := 100

@export var gold := STARTING_GOLD

# What word was played and the total score from that word.
var words_this_run: Dictionary[String, int] = {}

func add_gold(gold_added: int) -> void:
	gold += gold_added

func remove_gold(gold_lost: int) -> void:
	gold -= gold_lost
