class_name LetterTile
extends Node2D

enum TileType {BASIC, STONED, LOCKED, BURNING, PLAGUED, CRUMBLING}
enum TileLetter {A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z}
enum NotchTypes {EMPTY, REPEATING, ECHOING, VAPORIZING, WEIGHTED, INERT, GILDED}

@export var type: TileType
@export var letter: TileLetter
@export var notch1: NotchTypes
@export var notch2: NotchTypes
@export var notch3: NotchTypes
@export var tile_index: int
@export var grid_index: int
@export var target: Vector2

func new_tile(_type, _letter, _notch1, _notch2, _notch3, _tile_index) -> LetterTile:
	type = _type
	letter = _letter
	notch1 = _notch1
	notch2 = _notch2
	notch3 = _notch3
	tile_index = _tile_index
	return self
	
