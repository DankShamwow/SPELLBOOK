extends Node

var EnemyAttackCount = 1

var EnemyDeck = [
LetterTile.new().new_tile(LetterTile.TileType.STONED, LetterTile.TileLetter.P, LetterTile.NotchTypes.REINFORCED, LetterTile.NotchTypes.REINFORCED, LetterTile.NotchTypes.REINFORCED, 0),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.E, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 1),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.B, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 2),
LetterTile.new().new_tile(LetterTile.TileType.STONED, LetterTile.TileLetter.B, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 3),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.L, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 4),
LetterTile.new().new_tile(LetterTile.TileType.BASIC, LetterTile.TileLetter.E, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, 5),
]

var EnemyAttack0 = [0,1,2,3,4,5,]

var EnemyStatusPackage0 = []

var EnemyAttackList = [
EnemyAttack0,
]

var EnemyAttackNumbers = [0,]

var EnemyAttackTargets = [
"PLAYER",
]

var EnemyAttackIntents = [
"ATTACK",
]

var EnemyStatusPackageList = [
EnemyStatusPackage0,
]
