extends Area2D
class_name MapRoom

signal selected(room: Room)

var available := false : set = set_available
var room: Room : set = set_room
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
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)

#func set_available(new_value: bool) -> void:
	#available = new_value
	#if available:

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not available or not event.is_action_pressed("left_click"):
		return
	
	room.selected = true
	animation_player.play("select")
	
func _on_map_room_selected() -> void:
	selected.emit(room)
