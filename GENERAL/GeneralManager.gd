extends Node

var current_scene   = null

## current_deck is the list of LetterTiles in the player's deck.
var current_deck		= []

## available_tiles is the list of LetterTiles remaining in the deck.
var available_tiles		= []

## tiles_in_play is the list of LetterTiles currently in the grid or being used to play a word.
var tiles_in_play		= []

## buffered_tiles is the list of LetterTiles that was just played, and will be returned to the
## list of available tiles at the start of the next turn, or when the next shuffling event happens to the player's deck.
var buffered_tiles		= []

## current_relics is the list of Relics that the player currently has.
var current_relics		= []

## modified_wordlist is the list of words that has been added to by various Relics.
var modified_wordlist 	= []

## scored_letter_count is the sum total of the numbers that have been scored.
var scored_letter_count = 0

## played_words_count is the sum total of the number of words that have been played.
var played_words_count 	= 0
