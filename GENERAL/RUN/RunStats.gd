extends Node
class_name RunStats

## The current player character.
var current_character 			= GeneralManager.current_character

## current_deck is the list of LetterTiles in the player's deck.
var current_deck				= GeneralManager.current_deck

## current_combat_deck is the list of LetterTiles in the player's deck for this combat only.
var current_combat_deck			= GeneralManager.current_combat_deck

## available_tiles is the list of LetterTiles remaining in the deck.
var available_tiles				= GeneralManager.available_tiles

## priority_draw_list is the list of LetterTiles that should be drawn first.
var priority_draw_list 			= GeneralManager.priority_draw_list

## tiles_in_play is the list of LetterTiles currently in the grid or being used to play a word.
var tiles_in_play				= GeneralManager.tiles_in_play

## buffered_tiles is the list of LetterTiles that was just played, and will be returned to the
## list of available tiles at the start of the next turn, or when the next shuffling event happens to the player's deck.
var buffered_tiles				= GeneralManager.buffered_tiles

## destryoed_tiles is the list of LetterTiles that should be excluded for the current combat, and
## will be added back into circulation at the start of the next combat.
var destroyed_tiles				= GeneralManager.destroyed_tiles

## vaporized_tiles is the list of LetterTiles that will be removed from current_deck at the end of this combat.
var vaporized_tiles				= GeneralManager.vaporized_tiles

## current_relics is the list of Relics that the player currently has.
var current_relics				= GeneralManager.current_relics

## currently_owned_books is the list of books that the player owns.
var currently_owned_books		= GeneralManager.currently_owned_books

## currently_borrowed_relics is the list of relics that the player is currently borrowing.
var currently_borrowed_relics 	= GeneralManager.currently_borrowed_relics

## borrowed_relics_count is the number of relics that the player is currently borrowing.
## This should not exceed the borrow limit set in the Character's script.
var borrowed_relics_count		= GeneralManager.borrowed_relics_count

## scored_tile_count is the sum total of the numbers that have been scored.
var scored_tile_count: 			= GeneralManager.scored_tile_count

## played_words_count is the sum total of the number of words that have been played.
var played_words_count 			= GeneralManager.played_words_count

## played_words_dict is the list of words played this run as well as their scores.
var played_words_dict: 			= GeneralManager.played_words_dict

## bonus_word_list starts as an empty dictionary but is populated as more relics are acquired during a run.
var bonus_word_list: 			= GeneralManager.bonus_word_list

## chapter_combat_clear_count tracks how many combats have been completed in the current chapter
var chapter_combat_clear_count 	= GeneralManager.chapter_combat_clear_count

## chapter_boss_encounter is the encounter that gets used for the chapter boss, as well as for the graphics on the map.
var chapter_boss_encounter: 	= GeneralManager.chapter_boss_encounter

## combat_encounter is the currently prepared combat encounter to be loaded into the combat scene.
var combat_encounter: 			= GeneralManager.combat_encounter

## prefix_array is a list of currently granted prefixes that can be added to words.
var prefix_array: 				= GeneralManager.prefix_array

## suffix_array is a list of currently granted suffixes that can be added to words.
var suffix_array: 				= GeneralManager.suffix_array

## map_data contains all of the map nodes and their states.
var map_data: Array[Array] = []

### Data pulled from other places that isn't important enough to be saved.

var starting_bag = StartingTiles.StartingTileArray

var character_path = GeneralManager.character_path

### Functions that play with the above data.
