extends Node

var EnemyAttackCount = 3

var EnemyDeck = [
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.B, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 0),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.A, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 1),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.B, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 2),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.B, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 3),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.L, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 4),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.E, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 5),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.W, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 6),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.H, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 7),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.I, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 8),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.M, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 9),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.P, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 10),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.E, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 11),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.R, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 12),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.D, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 13),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.O, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 14),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.O, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 15),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.M, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 16),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.S, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 17),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.A, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 18),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.Y, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 19),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.E, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 20),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.R, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 21),
]

var EnemyAttack0 = [0,1,2,3,4,5,]

var EnemyAttack1 = [6,7,8,9,10,11,12,]

var EnemyAttack2 = [13,14,15,16,17,18,19,20,21,]

var EnemyStatusPackage0 = [["WARPED_DEBUFF", 3, 1, 3, "PLAYER"],]

var EnemyStatusPackage1 = []

var EnemyStatusPackage2 = []

var EnemyAttackList = [
EnemyAttack0,
EnemyAttack1,
EnemyAttack2,
]

var EnemyAttackNumbers = [0,1,2,]

var EnemyAttackTargets = [
"PLAYER",
"SELF",
"PLAYER",
]

var EnemyAttackIntents = [
"ATTACK_DEBUFF",
"DEFEND",
"ATTACK",
]

var EnemyStatusPackageList = [
EnemyStatusPackage0,
EnemyStatusPackage1,
EnemyStatusPackage2,
]
