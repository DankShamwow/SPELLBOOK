extends Node

var current_scene = null

var tile: LetterTile

var starting_deck_numbers = [4, 2, 2, 4, 5, 2, 2, 1, 4, 0, 0, 2, 2, 3, 4, 2, 0, 3, 2, 3, 2, 1, 1, 0, 1, 0]
var StartingTileArray = []

func generate_starting_tiles():
	for i in starting_deck_numbers.size():
		for j in starting_deck_numbers[i]:
			print("Adding New Tile!")
			var new_tile = LetterTile.new().new_tile(LetterTile.TileType.BASIC, i, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, StartingTileArray.size())
			StartingTileArray.append(new_tile)
