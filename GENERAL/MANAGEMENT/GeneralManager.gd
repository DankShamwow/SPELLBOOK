extends Node

var is_combat_active 	:= false

var is_bag_open			:= false

var is_map_open			:= false

var rewards_screen_open := false

## Path to the currently open rewards screen, if there is one. If not, one can be opened.
var rewards_screen_path = null

## character_path is the path from root to player's character; the character should NEVER be uninstantiated.
var character_path		= null

var current_character 	= null

var replace_character_path = null

## Current map node type for making things work nicer.
var current_location = null

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

## scored_tile_count is the sum total of the numbers that have been scored.
var scored_tile_count: int = 0

## played_words_count is the sum total of the number of words that have been played.
var played_words_count 	= 0

## current_target is the last GameEntity that the player has clicked on for targeting.
var current_target: GameEntity

## who_has_initiative is the GameEntity that currently has the initiative.
var who_has_initiative: GameEntity

## point_values determines the number of points that a letter scores for.
var point_values  	:= [1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10]

## word_list starts as an empty dictionary but is populated at startup with the contents of a wordlist file.
var word_list: Dictionary[String, bool] = {}

## bonus_word_list starts as an empty dictionary but is populated as more relics are acquired during a run.
var bonus_word_list: Dictionary[String, bool] = {}

## scoring_is_active is a flag that is used to determine if scoring is happening during combat.
var scoring_is_active: bool = false
 
## text_file_path is the path to the wordlist. Currently, this is hard-set to be the default wordlist.
## This will be changed later when characters start to need their own wordlists.
var text_file_path = "res://WORDLISTS/words_filtered.txt"

## common_notch_ids for the notch drop table. These correspond to:
## Weighted, Flaming, Reinforced, Patient, Balanced, Local, Distant, and Potent.
var common_notch_ids = [3, 7, 9, 11, 14, 15, 16, 18]

## uncommon_notch_ids for the notch drop table. These correspond to:
## Repeating, Echoing, Vaporizing, Inert, Gilded, Rejuvenating, and Quick.
var uncommon_notch_ids = [0, 1, 2, 4, 5, 8, 12]

## rare_notch_ids for the notch drop table. These correspond to:
## Phantom, Eager, Overloaded, Prickly, and Lexical.
var rare_notch_ids = [6, 10, 13, 17, 19]

## Generated tiles aren't allowed to spawn with Lexical notches. These correspond to:
## Phantom, Eager, Overloaded, and Prickly
var rare_notch_ids_no_lexical = [6, 10, 13, 17]

## List of all enum values for consonant letters.
var consonant_letter_ids = [1, 2, 3, 5, 6, 7, 9, 10, 11, 12, 13, 15, 16, 17, 18, 19, 21, 22, 23, 25]

## List of all enum values for vowel letters.
var vowel_letter_ids = [0, 4, 8, 14, 20, 24]

## List of all enum values for unwieldy consonants. Also used for the least common Lexical pool.
## J, K, Q, X, Z
var rare_consonant_pool = [9, 10, 16, 22, 25]

## List of all enum values for the most common Lexical pool.
## G, I, N, R, S
var tier_1_lexical_pool = [6, 8, 13, 17, 18]

## List of all enum values for the second most common Lexical pool.
## C, D, E, L, O
var tier_2_lexical_pool = [2, 3, 4, 11, 14]

## List of all enum values for the middle rarity Lexical pool. This is the only pool with six letters.
## A, B, M, T, U, Y
var tier_3_lexical_pool = [0, 1, 12, 19, 20, 24]

## List of all enum values for the second least common Lexical pool.
## F, H, P, V, W
var tier_4_lexical_pool = [5, 7, 15, 21, 22]

## chapter_combat_clear_count tracks how many combats have been completed in the current chapter
var chapter_combat_clear_count = 0
## chapter_boss_encounter is the encounter that gets used for the chapter boss, as well as for the graphics on the map.
var chapter_boss_encounter: Resource

## combat_encounter is the currently prepared combat encounter to be loaded into the combat scene.
var combat_encounter: Resource

## current_word is the word in play.
var current_word: String = ""

## true_word is a valid word stripped of its prefixes or suffixes.
var true_word: String = ""

## prefix_array is a list of currently granted prefixes that can be added to words.
var prefix_array: Array[String] = []

## suffix_array is a list of currently granted suffixes that can be added to words.
var suffix_array: Array[String] = []

## Not to be confused with remove_specific_tile_from_deck(); this function clears out all of the 
## temporary and vaporized tiles at the end of combat.
func remove_tiles_from_deck():
	# This should work, in theory. We'll make a backup of the player's deck just to be safe.
	var _old_deck = current_deck.duplicate()
	
	# Clear the player's current deck. This is a very dangerous and stupid operation to do.
	# At least we made a backup of it.
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
func remove_specific_tile_from_deck(tile_index):
	current_deck.remove_at(tile_index)

func rearrange_deck_tiles():
	for i in current_deck.size():
		current_deck[i].tile_index = i

## Populates the game's word dictionary. This will need to be reworked after the Inquisitor is implemented, since his wordlist is separate.
func prepare_word_dict():
	bonus_word_list.clear()
	prefix_array.clear()
	suffix_array.clear()
	var file = FileAccess.open(text_file_path, FileAccess.READ)
	while file.get_position() < file.get_length():
		var filter = file.get_line()
		if filter.length() >= 3:
			var filter_pass = str(filter[0] + filter[0] + filter[0])
			if not filter == filter_pass and not word_list.has(filter):
				word_list[str(filter)] = true

func add_bonus_words(bonus_words: Dictionary):
	bonus_word_list.merge(bonus_words)

func add_bonus_prefixes(prefixes: Array[String]):
	prefix_array.append(prefixes)

func add_bonus_suffixes(suffixes: Array[String]):
	suffix_array.append(suffixes)

func score_tile_quiet(scored_tile):
	var letter_score = 0
	if scored_tile.type == LetterTile.TileType.BASIC or scored_tile.type == LetterTile.TileType.LOCKED:
		letter_score += point_values[scored_tile.played_letter]

	elif scored_tile.type == LetterTile.TileType.STONED:
		letter_score += 0
		
	elif scored_tile.type == LetterTile.TileType.BURNING:
		letter_score += point_values[scored_tile.played_letter]
		
	elif scored_tile.type == LetterTile.TileType.PLAGUED:
		letter_score += point_values[scored_tile.played_letter] - 1
		if letter_score == 0:
			letter_score += 1

	elif scored_tile.type == LetterTile.TileType.CRUMBLING:
		letter_score += point_values[scored_tile.played_letter]

	if scored_tile.notch1 == LetterTile.NotchTypes.POTENT:
		letter_score += 3
	if scored_tile.notch2 == LetterTile.NotchTypes.POTENT:
		letter_score += 3
	if scored_tile.notch3 == LetterTile.NotchTypes.POTENT:
		letter_score += 3

	if scored_tile.notch1 == LetterTile.NotchTypes.PATIENT:
		letter_score += scored_tile.current_age * 2
	if scored_tile.notch2 == LetterTile.NotchTypes.PATIENT:
		letter_score += scored_tile.current_age * 2
	if scored_tile.notch3 == LetterTile.NotchTypes.PATIENT:
		letter_score += scored_tile.current_age * 2

	if scored_tile.notch1 == LetterTile.NotchTypes.QUICK and scored_tile.current_age == 0:
		letter_score += 5
	if scored_tile.notch2 == LetterTile.NotchTypes.QUICK and scored_tile.current_age == 0:
		letter_score += 5
	if scored_tile.notch3 == LetterTile.NotchTypes.QUICK and scored_tile.current_age == 0:
		letter_score += 5

	if scored_tile.notch1 == LetterTile.NotchTypes.DISTANT:
		letter_score += scored_tile.word_index
	if scored_tile.notch2 == LetterTile.NotchTypes.DISTANT:
		letter_score += scored_tile.word_index
	if scored_tile.notch3 == LetterTile.NotchTypes.DISTANT:
		letter_score += scored_tile.word_index
		
	if scored_tile.notch1 == LetterTile.NotchTypes.LOCAL:
		letter_score += (scored_tile.word_length - scored_tile.word_index - 1)
	if scored_tile.notch2 == LetterTile.NotchTypes.LOCAL:
		letter_score += (scored_tile.word_length - scored_tile.word_index - 1)
	if scored_tile.notch3 == LetterTile.NotchTypes.LOCAL:
		letter_score += (scored_tile.word_length - scored_tile.word_index - 1)

	if scored_tile.notch1 == LetterTile.NotchTypes.BALANCED:
		if scored_tile.word_length == scored_tile.word_index:
			letter_score += 0
		elif floor(scored_tile.word_length / 2) - scored_tile.word_index == 0:
			if scored_tile.word_length % 2 == 1:
				letter_score += 2 * scored_tile.word_index
			else:
				letter_score += (2 * (scored_tile.word_index - 1))
		elif scored_tile.word_index < floor(scored_tile.word_length / 2):
			letter_score += 2 * (scored_tile.word_index)
		elif scored_tile.word_index >= floor(scored_tile.word_length / 2):
			letter_score += 2 * (scored_tile.word_length - scored_tile.word_index - 1)
			
	if scored_tile.notch2 == LetterTile.NotchTypes.BALANCED:
		if scored_tile.word_length == scored_tile.word_index:
			letter_score += 0
		elif floor(scored_tile.word_length / 2) - scored_tile.word_index == 0:
			if scored_tile.word_length % 2 == 1:
				letter_score += 2 * scored_tile.word_index
			else:
				letter_score += (2 * (scored_tile.word_index - 1))
		elif scored_tile.word_index < floor(scored_tile.word_length / 2):
			letter_score += 2 * (scored_tile.word_index)
		elif scored_tile.word_index >= floor(scored_tile.word_length / 2):
			letter_score += 2 * (scored_tile.word_length - scored_tile.word_index - 1)

	if scored_tile.notch3 == LetterTile.NotchTypes.BALANCED:
		if scored_tile.word_length == scored_tile.word_index:
			letter_score += 0
		elif floor(scored_tile.word_length / 2) - scored_tile.word_index == 0:
			if scored_tile.word_length % 2 == 1:
				letter_score += 2 * scored_tile.word_index
			else:
				letter_score += (2 * (scored_tile.word_index - 1))
		elif scored_tile.word_index < floor(scored_tile.word_length / 2):
			letter_score += 2 * (scored_tile.word_index)
		elif scored_tile.word_index >= floor(scored_tile.word_length / 2):
			letter_score += 2 * (scored_tile.word_length - scored_tile.word_index - 1)

	return letter_score
