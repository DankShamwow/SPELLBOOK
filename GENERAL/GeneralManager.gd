extends Node

var current_scene   = null

var current_deck	= []

## available_tiles is the list of LetterTiles remaining in the deck.
var available_tiles	= []

## tiles_in_play is the list of LetterTiles currently in the grid or being used to play a word.
var tiles_in_play	= []

## buffered_tiles is the list of LetterTiles that was just played, and will be returned to the
## list of available tiles at the start of the next turn, or when the next shuffling event happens to the player's deck.
var buffered_tiles	= []

var current_relics	= []
