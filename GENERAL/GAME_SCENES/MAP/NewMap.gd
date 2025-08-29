extends Control
class_name NewMap

const SCROLL_SPEED := 30
const MAP_ROOM = preload("res://GENERAL/GAME_SCENES/MAP/MapRoom.tscn")
const MAP_LINE = preload("res://GENERAL/GAME_SCENES/MAP/MapLine.tscn")

@onready var lines: Node2D = %Lines
@onready var rooms: Node2D = %Rooms
@onready var visuals: Node2D = %Visuals
@onready var camera_2d: Camera2D = %Camera2D

var camera_edge_x: float

signal map_toggle(toggled_on)

func _input(event: InputEvent) -> void:
	if GeneralManager.is_bag_open == false:
		if event.is_action_pressed("scroll_up"):
			print("scrolling up!")
			camera_2d.position.x -= SCROLL_SPEED
		elif event.is_action_pressed("scroll_down"):
			print("scrolling down!")
			camera_2d.position.x += SCROLL_SPEED

		camera_2d.position.x = clamp(camera_2d.position.x, 50, camera_edge_x)

func _on_map_bringup(map_data: Array[Array], camera_position: float = 0.0):
	camera_edge_x = self.get_parent().get_parent().X_DIST * (self.get_parent().get_parent().COLUMNS - 2) * 1.25
	%Camera2D.position.x = camera_position
	for column: Array in map_data:
		for room: Room in column:
			if room.next_rooms.size() > 0:
				var new_map_room := MAP_ROOM.instantiate() as MapRoom
				rooms.add_child(new_map_room)
				new_map_room.room = room
				new_map_room.selected.connect(self._on_map_room_selected)
				_connect_lines(room)
				
				if room.selected and room.column <= self.get_parent().get_parent().sections_crossed:
					new_map_room.show_selected()
			
		
	var new_map_room := MAP_ROOM.instantiate() as MapRoom
	rooms.add_child(new_map_room)
	new_map_room.room = map_data[15][3]
	new_map_room.selected.connect(self._on_map_room_selected)
	_connect_lines(map_data[15][3])
	
	var map_height_pixels := 200
	%Visuals.position.x = 50
	%Visuals.position.y = ((get_viewport_rect().size.y - map_height_pixels) / 2) - 5
	
	%FadeIn._on_map_bringup()
	%MapBackground._on_map_bringup()
	%Visuals._on_map_bringup()
	await get_tree().create_timer(0.25).timeout
	
	return true
	
func _connect_lines(room: Room) -> void:
	if room.previous_rooms.is_empty():
		return
	
	for previous: Room in room.previous_rooms:
		var new_map_line := MAP_LINE.instantiate() as Line2D
		new_map_line.add_point(previous.position)
		new_map_line.add_point(room.position)
		lines.add_child(new_map_line)

func unlock_section(section: int):
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.column == section:
			map_room.available = true
			map_room.add_to_group("Available Rooms")
			
func unlock_next_rooms() -> void:
	for map_room: MapRoom in rooms.get_children():
		if self.get_parent().get_parent().last_room.next_rooms.has(map_room.room):
			map_room.available = true
			map_room.add_to_group("Available Rooms")

func _on_map_room_selected(room: Room, map_room: MapRoom) -> void:
	get_tree().call_group("Available Rooms", "disable_button")
	map_room.available = false
	map_room.room.selected = true
	
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(%Camera2D, "position:x", room.position.x + 50, 0.35)
	await get_tree().create_timer(0.40).timeout
	%Camera2D.position.x = room.position.x + 50
	
	self.get_parent().get_parent().last_room = room
	self.get_parent().get_parent().sections_crossed += 1
	self.get_parent().get_parent().set_unlock_section = false
	await get_tree().create_timer(0.75).timeout
	perform_map_selection_procedure(room)

func perform_map_shutdown_procedure():
	self.get_parent().get_parent().last_camera_position = %Camera2D.position.x
	%FadeIn._on_map_shutdown()
	%MapBackground._on_map_shutdown()
	%Visuals._on_map_shutdown()
	GeneralManager.is_map_open = false
	await get_tree().create_timer(0.25).timeout
	self.queue_free()
	
func perform_map_selection_procedure(room: Room):
	self.get_parent().get_parent().last_camera_position = %Camera2D.position.x
	%FadeIn._on_map_shutdown()
	%MapBackground._on_map_shutdown()
	%Visuals._on_map_shutdown()
	GameEventHandler.map_exited.emit(room)
	GeneralManager.is_map_open = false
	await get_tree().create_timer(0.25).timeout
	self.queue_free()
