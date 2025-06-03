## LetterTile is a piece of data that defines what a tile's attributes are.
class_name LetterTile
extends Resource

enum TileType {BASIC, STONED, LOCKED, BURNING, PLAGUED, CRUMBLING}
enum TileLetter {A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z}
enum NotchTypes {EMPTY, REPEATING, ECHOING, VAPORIZING, WEIGHTED, INERT, GILDED, PHANTOM, FLAMING, REJUVENATING, REINFORCED}

@export var type: TileType
@export var letter: TileLetter
@export var bonus_letter1 := ""
@export var bonus_letter2 := ""
@export var bonus_letter3 := ""
@export var notch1: NotchTypes
@export var notch2: NotchTypes
@export var notch3: NotchTypes
@export var tile_index: int
@export var grid_index: int
@export var xth_letter_played: int # Do I even need to keep this in a place so deep into things?
@export var target: Vector2
@export var is_friendly := true
@export var is_temporary := false


# Notch-specific Flagging

# echoNUM determines if a tile has Echoed this draw. True means that it has not.
# Defaults to false due to Weighted tiles. Flag is set to true when drawn if the
# tile has the Echoing notch in the relevant slot.
var echo1 := false
var echo2 := false
var echo3 := false
var echoed_this_word := false

# healNUM determines if a Rejuvenating tile has healed this combat.
# False means that it has not. Flag changes when activated.
var heal1 := false
var heal2 := false
var heal3 := false

# These flags determine combat states.
var no_buffer := false
var vaporized := false

# Functions
## new_tile creates a tile based on the information given.
func new_tile(_type, _letter, _notch1, _notch2, _notch3, _tile_index) -> LetterTile:
	type = _type
	letter = _letter
	notch1 = _notch1
	notch2 = _notch2
	notch3 = _notch3
	tile_index = _tile_index
	return self
	
func generate_tile(_type, _letter, _notch1, _notch2, _notch3) -> LetterTile:
	type = _type
	letter = _letter
	notch1 = _notch1
	notch2 = _notch2
	notch3 = _notch3
	return self
