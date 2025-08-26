extends Resource
class_name Room

enum RoomType {UNASSIGNED, MONSTER, ELITE, TREASURE, LIBRARY, SHOP, REST, RANDOM, BOSS}

@export var type: RoomType
@export var row: int
@export var column: int
@export var position: Vector2
@export var offset: Vector2
@export var next_rooms: Array[Room]
@export var previous_rooms: Array[Room]
@export var selected := false
@export var is_valid := false

var upper_neighbor: Room
var lower_neighbor: Room

func _to_string() -> String:
	return "%s (%s)" % [row, RoomType.keys()[type]]
