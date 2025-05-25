extends Node

var current_scene = null

var tile: LetterTile
var StartingTileArray = []

func _randomize_start_tiles():
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.A, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 0))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.B, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 1))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.C, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 2))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.D, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 3))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.E, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 4))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.F, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 5))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.G, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 6))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.H, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 7))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.I, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 8))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.J, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 9))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.K, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 10))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.L, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 11))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.M, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 12))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.N, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 13))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.O, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 14))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.P, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 15))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.Q, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 16))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.R, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 17))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.S, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 18))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.T, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 19))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.U, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 20))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.V, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 21))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.W, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 22))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.X, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 23))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.Y, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 24))
	StartingTileArray.append(LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.Z, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 25))
	
	for i in 72:
		var random_tile_type = randi() % 6
		var random_letter = randi() % 26
		var random_notch1 = randi() % 11
		var random_notch2 = randi() % 11
		var random_notch3 = randi() % 11
		var tile_index = i + 25
		
		if random_notch1 == 5 or random_notch2 == 5 or random_notch3 == 5:
			random_tile_type = 0
		
		StartingTileArray.append(LetterTile.new().new_tile(random_tile_type, random_letter, random_notch1, random_notch2, random_notch3, tile_index))

	return true
