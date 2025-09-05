extends Node

var EnemyAttackCount = 3

var EnemyDeck = [
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.H, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 0),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.I, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 1),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.S, LetterTile.NotchTypes.REPEATING, LetterTile.NotchTypes.REPEATING, LetterTile.NotchTypes.REPEATING, 2),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.S, LetterTile.NotchTypes.REPEATING, LetterTile.NotchTypes.REPEATING, LetterTile.NotchTypes.REPEATING, 3),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.L, LetterTile.NotchTypes.POTENT, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 4),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.U, LetterTile.NotchTypes.POTENT, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 5),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.N, LetterTile.NotchTypes.POTENT, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 6),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.G, LetterTile.NotchTypes.POTENT, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 7),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.E, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 8),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.G, LetterTile.NotchTypes.POTENT, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 9),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.O, LetterTile.NotchTypes.POTENT, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 10),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.U, LetterTile.NotchTypes.POTENT, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 11),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.G, LetterTile.NotchTypes.POTENT, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 12),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.E, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 13),
]

var EnemyAttack0 = [0,1,2,3,]

var EnemyAttack1 = [4,5,6,7,8,]

var EnemyAttack2 = [9,10,11,12,13,]

var EnemyStatusPackage0 = []

var EnemyStatusPackage1 = []

var EnemyStatusPackage2 = [["BLEED_DEBUFF", 2, 1, 2, "PLAYER"],]

var EnemyAttackList = [
EnemyAttack0,
EnemyAttack1,
EnemyAttack2,
]

var EnemyAttackNumbers = [0,1,2,]

var EnemyAttackTargets = [
"SELF",
"PLAYER",
"PLAYER",
]

var EnemyAttackIntents = [
"DEFEND",
"ATTACK",
"ATTACK_DEBUFF",
]

var EnemyStatusPackageList = [
EnemyStatusPackage0,
EnemyStatusPackage1,
EnemyStatusPackage2,
]
