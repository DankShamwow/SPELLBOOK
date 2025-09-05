extends Node

var EnemyAttackCount = 3

var EnemyDeck = [
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.P, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 0),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.O, LetterTile.NotchTypes.BALANCED, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 1),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.K, LetterTile.NotchTypes.BALANCED, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 2),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.E, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 3),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.C, LetterTile.NotchTypes.REINFORCED, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 4),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.U, LetterTile.NotchTypes.REINFORCED, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 5),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.R, LetterTile.NotchTypes.REINFORCED, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 6),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.L, LetterTile.NotchTypes.REINFORCED, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 7),
LetterTile.new().new_tile(LetterTile.TileType.STONED, LetterTile.TileLetter.S, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 8),
LetterTile.new().new_tile(LetterTile.TileType.STONED, LetterTile.TileLetter.H, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 9),
LetterTile.new().new_tile(LetterTile.TileType.STONED, LetterTile.TileLetter.A, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 10),
LetterTile.new().new_tile(LetterTile.TileType.STONED, LetterTile.TileLetter.R, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 11),
LetterTile.new().new_tile(LetterTile.TileType.STONED, LetterTile.TileLetter.P, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 12),
LetterTile.new().new_tile(LetterTile.TileType.STONED, LetterTile.TileLetter.E, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 13),
LetterTile.new().new_tile(LetterTile.TileType.STONED, LetterTile.TileLetter.N, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 14),
]

var EnemyAttack0 = [0,1,2,3,]

var EnemyAttack1 = [4,5,6,7,]

var EnemyAttack2 = [8,9,10,11,12,13,14,]

var EnemyStatusPackage0 = []

var EnemyStatusPackage1 = []

var EnemyStatusPackage2 = [["THORNS_BUFF", 2, 0, 1, "SELF"],]

var EnemyAttackList = [
EnemyAttack0,
EnemyAttack1,
EnemyAttack2,
]

var EnemyAttackNumbers = [0,1,2,]

var EnemyAttackTargets = [
"PLAYER",
"SELF",
"SELF",
]

var EnemyAttackIntents = [
"ATTACK",
"DEFEND",
"BUFF",
]

var EnemyStatusPackageList = [
EnemyStatusPackage0,
EnemyStatusPackage1,
EnemyStatusPackage2,
]
