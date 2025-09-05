extends Node

var seed_randomizer = RandomNumberGenerator.new()

var tile_rng = 			RandomNumberGenerator.new()
var relic_rng = 		RandomNumberGenerator.new()
var event_rng = 		RandomNumberGenerator.new()
var map_rng = 			RandomNumberGenerator.new()
var encounter_rng = 	RandomNumberGenerator.new()
var enemy_rng =			RandomNumberGenerator.new()
var debuff_rng = 		RandomNumberGenerator.new()
var reward_rng = 		RandomNumberGenerator.new()
var various_rng = 		RandomNumberGenerator.new()

var random_seed: int

func _ready() -> void:
	seed_randomizer = RandomNumberGenerator.new()
	random_seed = seed_randomizer.get_seed()
	
	_set_tile_rng(random_seed)
	_set_relic_rng(random_seed)
	_set_event_rng(random_seed)
	_set_map_rng(random_seed)
	_set_encounter_rng(random_seed)
	_set_enemy_rng(random_seed)
	_set_debuff_rng(random_seed)
	_set_reward_rng(random_seed)
	_set_various_rng(random_seed)
	
func _set_rng_seed(new_seed: int) -> void:
	random_seed = new_seed
	
	_set_tile_rng(random_seed)
	_set_relic_rng(random_seed)
	_set_event_rng(random_seed)
	_set_map_rng(random_seed)
	_set_encounter_rng(random_seed)
	_set_enemy_rng(random_seed)
	_set_debuff_rng(random_seed)
	_set_reward_rng(random_seed)
	_set_various_rng(random_seed)

func _set_tile_rng(random_seed):
	tile_rng.set_seed(random_seed)
	
func _set_relic_rng(random_seed):
	relic_rng.set_seed(random_seed)
	
func _set_event_rng(random_seed):
	event_rng.set_seed(random_seed)

func _set_map_rng(random_seed):
	map_rng.set_seed(random_seed)

func _set_encounter_rng(random_seed):
	encounter_rng.set_seed(random_seed)

func _set_enemy_rng(random_seed):
	enemy_rng.set_seed(random_seed)

func _set_debuff_rng(random_seed):
	debuff_rng.set_seed(random_seed)

func _set_reward_rng(random_seed):
	reward_rng.set_seed(random_seed)

func _set_various_rng(random_seed):
	various_rng.set_seed(random_seed)
	


# rng.seed = hash("player_specified_seed")
# rng.state = state_to_be_saved
