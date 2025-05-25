extends Node

var EnemyAttackCount = 3

var EnemyDeck = [
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.T, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 0),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.E, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 1),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.S, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 2),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.T, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 3),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.C, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 4),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.H, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 5),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.E, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 6),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.C, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 7),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.K, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 8),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.T, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 9),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.E, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 10),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.S, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 11),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.T, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 12),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.I, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 13),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.N, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 14),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.G, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 15),
]

var EnemyAttack0 = [
0,
1,
2,
3,
]

var EnemyAttack1 = [
4,
5,
6,
7,
8,
]

var EnemyAttack2 = [
9,
10,
11,
12,
13,
14,
15,
]

var EnemyAttackList = [
EnemyAttack0,
EnemyAttack1,
EnemyAttack2,
]
