extends Node2D

var starting_bag = StartingTiles.StartingTileArray
var current_deck = TileManager.current_deck
var available_tiles = TileManager.available_tiles
var tiles_in_play = TileManager.tiles_in_play

# Called when the node enters the scene tree for the first time.
func _init():
	for i in starting_bag.size():
		current_deck.append(starting_bag[i])
		available_tiles.append(starting_bag[i])
