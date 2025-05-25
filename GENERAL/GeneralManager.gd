extends Node

var current_scene   = null

## current_deck is the list of LetterTiles in the player's deck.
var current_deck		= []

## current_combat_deck is the list of LetterTiles in the player's deck for this combat only.
var current_combat_deck	= []

## available_tiles is the list of LetterTiles remaining in the deck.
var available_tiles		= []

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

func rearrange_deck_tiles():
	for i in current_deck.size():
		current_deck[i].tile_index = i
