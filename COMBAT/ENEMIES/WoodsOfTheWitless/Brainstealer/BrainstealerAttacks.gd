extends Node

var EnemyAttackCount = 3

var EnemyDeck = [
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.L, LetterTile.NotchTypes.REJUVENATING, LetterTile.NotchTypes.REJUVENATING, LetterTile.NotchTypes.REJUVENATING, 0),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.E, LetterTile.NotchTypes.REJUVENATING, LetterTile.NotchTypes.REJUVENATING, LetterTile.NotchTypes.REJUVENATING, 1),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.E, LetterTile.NotchTypes.REJUVENATING, LetterTile.NotchTypes.REJUVENATING, LetterTile.NotchTypes.REJUVENATING, 2),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.C, LetterTile.NotchTypes.REJUVENATING, LetterTile.NotchTypes.REJUVENATING, LetterTile.NotchTypes.REJUVENATING, 3),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.H, LetterTile.NotchTypes.REJUVENATING, LetterTile.NotchTypes.REJUVENATING, LetterTile.NotchTypes.REJUVENATING, 4),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.D, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 5),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.R, LetterTile.NotchTypes.REINFORCED, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 6),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.I, LetterTile.NotchTypes.REINFORCED, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 7),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.F, LetterTile.NotchTypes.REINFORCED, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 8),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.T, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 9),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.D, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 10),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.E, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 11),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.V, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 12),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.O, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 13),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.U, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 14),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.R, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 15),
]

var EnemyAttack0 = [0,1,2,3,4,]

var EnemyAttack1 = [5,6,7,8,9,]

var EnemyAttack2 = [10,11,12,13,14,15,]

var EnemyStatusPackage0 = []

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
"ATTACK_BUFF",
"DEFEND",
"ATTACK",
]

var EnemyStatusPackageList = [
EnemyStatusPackage0,
EnemyStatusPackage1,
EnemyStatusPackage2,
]
