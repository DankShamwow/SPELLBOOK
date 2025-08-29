extends Control
class_name MapRoom

signal selected(room: Room, map_room: MapRoom)

var available := false : set = set_available
var room: Room : set = set_room
@export var button: TextureButton
@onready var animation_player := %AnimationPlayer

func _ready() -> void:
	var test_room := Room.new()
	test_room.type = Room.RoomType.REST
	test_room.position = Vector2(200, 200)
	room = test_room

func set_room(room_type: Room):
	room = room_type
	position = room.position
	%Map_Circle.rotation_degrees = randi_range(0, 360)
	if not room.type == Room.RoomType.BOSS:
		%Map_Icon.set_frame_coords(Vector2i(room.type, 0))
	
	if room.type == Room.RoomType.BOSS:
		%Map_Icon.set_frame_coords(Vector2i(2, 0))
		%Map_Icon.scale = Vector2(2.0, 2.0)

func set_available(new_value: bool) -> void:
	available = new_value
	
	if available:
		animation_player.play("highlight")
	elif not room.selected:
		animation_player.play("RESET")

func show_selected() -> void:
	var tween = %Map_Circle.create_tween()
	tween.tween_property(%Map_Circle, "modulate:a", 1, 0.1)

func disable_buttons() -> void:
	%MapButton.set_disabled(true)

func _on_map_button_pressed() -> void:
	if not available:
		return
	room.selected = true
	%MapButton.set_disabled(true)
	selected.emit(room, self)
	animation_player.play("select")
	
