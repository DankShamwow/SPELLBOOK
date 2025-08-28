extends Node

var is_combat_active 	:= false

var is_bag_open			:= false

var is_map_open			:= false

## character_path is the path from root to player's character; the character should NEVER be uninstantiated.
var character_path		= null

var current_character 	= null

var replace_character_path = null

## current_deck is the list of LetterTiles in the player's deck.
var current_deck		= []

## current_combat_deck is the list of LetterTiles in the player's deck for this combat only.
var current_combat_deck	= []

## available_tiles is the list of LetterTiles remaining in the deck.
var available_tiles		= []

## priority_draw_list is the list of LetterTiles that should be drawn first.
var priority_draw_list 	= []

## tiles_in_play is the list of LetterTiles currently in the grid or being used to play a word.
var tiles_in_play		= []

## buffered_tiles is the list of LetterTiles that was just played, and will be returned to the
## list of available tiles at the start of the next turn, or when the next shuffling event happens to the player's deck.
var buffered_tiles		= []

## destryoed_tiles is the list of LetterTiles that should be excluded for the current combat, and
## will be added back into circulation at the start of the next combat.
var destroyed_tiles		= []

## vaporized_tiles is the list of LetterTiles that will be removed from current_deck at the end of this combat.
var vaporized_tiles		= []

## current_relics is the list of Relics that the player currently has.
var current_relics		= []

## modified_wordlist is the list of words that has been added to by various Relics.
var modified_wordlist 	= []

## scored_letter_count is the sum total of the numbers that have been scored.
var scored_letter_count = 0

## played_words_count is the sum total of the number of words that have been played.
var played_words_count 	= 0

## current_target is the last GameEntity that the player has clicked on for targeting.
var current_target: GameEntity

## who_has_initiative is the GameEntity that currently has the initiative.
var who_has_initiative: GameEntity

## point_values determines the number of points that a letter scores for.
var point_values  	:= [1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10]

## mult_values determines the multiplier on the score based on the length of a word.
var mult_values		:= [1, 1, 2, 2, 3, 3, 4, 5, 7, 10, 13, 18, 24, 30, 35, 40, 50, 60, 80, 100]

## word_list starts as an empty dictionary but is populated at startup with the contents of a wordlist file.
var word_list := {}

## tile_scaling_factor is the scaling factor for tiles based on the length of a word. 
var tile_scaling_factor: float = 1.0


var text_file_path = "res://WORDLISTS/words_alpha.txt"

## Not to be confused with remove_tile_from_deck(); this function clears out all of the 
## temporary and vaporized tiles at the end of combat.
func remove_tiles_from_deck():
	# This should work, in theory. We'll make a backup of the player's deck just to be safe.
	var old_deck = current_deck.duplicate()
	current_deck.clear()
	
	# Flags are set on a per-tile basis. If a tile has the temporary or vaporized flag,
	# it isn't added back into the player's deck.
	for i in current_combat_deck.size():
		var tile_to_process = current_combat_deck[i]
		if tile_to_process.is_temporary == false:
			if tile_to_process.vaporized == false:
				current_deck.append(current_combat_deck[i])
		
	# Now we re-number every tile in the player's deck according to their index in the deck.
	rearrange_deck_tiles()

## Not to be confused with remove_tiles_from_deck(); this function removes a specified tile
## based on the given tile_index.
func remove_tile_from_deck(tile_index):
	current_deck.remove_at(tile_index)

func rearrange_deck_tiles():
	for i in current_deck.size():
		current_deck[i].tile_index = i

func prepare_word_dict():
	var file = FileAccess.open(text_file_path, FileAccess.READ)
	while file.get_position() < file.get_length():
		var filter = file.get_line()
		if filter.length() >= 3:
			var filter_pass = str(filter[0] + filter[0] + filter[0])
			if not filter == filter_pass:
				word_list[str(filter)] = true
