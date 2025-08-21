extends Node2D
class_name Map

const SCROLL_SPEED := 30
const MAP_ROOM = preload("res://GENERAL/GAME_SCENES/MAP/MapRoom.tscn")
const MAP_LINE = preload("res://GENERAL/GAME_SCENES/MAP/MapLine.tscn")

@onready var map_generator: MapGenerator = $MapGenerator
@onready var lines: Node2D = %Lines
@onready var rooms: Node2D = %Rooms
@onready var visuals: Node2D = %Visuals
@onready var camera_2d: Camera2D = %Camera2D

signal map_toggle(toggled_on)

var map_data: Array[Array]
var sections_crossed: int
var last_room: Room
var camera_edge_x: float
var map_open := false
var bag_open := false

func _ready() -> void:
	camera_edge_x = MapGenerator.X_DIST * (MapGenerator.SECTIONS - 1) * 1.25
	$MapGenerator.generate_map()

func on_run_start():
	generate_new_map()
	%MapButton.set_pressed_no_signal(true)
	_on_map_button_toggled(true)
	unlock_section(0)

func on_return_from_scene():
	%MapButton.set_pressed_no_signal(true)
	_on_map_button_toggled(true)

func close_map_on_scene_change():
	%MapButton.set_pressed(false)

func _on_map_button_toggled(toggled_on):
	if GeneralManager.is_bag_open == false:
		if GeneralManager.is_map_open == false:
			print("Map opening!")
			map_toggle.emit(toggled_on)
			show_map()
			GeneralManager.is_map_open = true
			%MapButton.set_disabled(true)
			await get_tree().create_timer(0.5).timeout
			%MapButton.set_disabled(false)
			
		elif GeneralManager.is_map_open == true:
			print("Map closing!")
			map_toggle.emit(toggled_on)
			%MapButton.set_disabled(true)
			await get_tree().create_timer(0.5).timeout
			hide_map()
			GeneralManager.is_map_open = false
			%MapButton.set_disabled(false)

func _input(event: InputEvent) -> void:
	if bag_open == false and camera_2d.enabled == true:
		if event.is_action_pressed("scroll_up"):
			print("scrolling up!")
			camera_2d.position.x += SCROLL_SPEED
		elif event.is_action_pressed("scroll_down"):
			print("scrolling down!")
			camera_2d.position.x -= SCROLL_SPEED

		camera_2d.position.x = clamp(camera_2d.position.x, 50, camera_edge_x)

func generate_new_map() -> void:
	sections_crossed = 0
	map_data = map_generator.generate_map()
	create_map()

func create_map() -> void:
	for current_section: Array in map_data:
		for room: Room in current_section:
			if room.next_rooms.size() > 0:
				_spawn_room(room)
	
	var middle := floori(MapGenerator.MAP_HEIGHT * 0.5)
	_spawn_room(map_data[MapGenerator.SECTIONS-1][middle])
	
	var map_height_pixels := MapGenerator.Y_DIST * (MapGenerator.MAP_HEIGHT - 3)
	visuals.position.x = 50
	visuals.position.y = (get_viewport_rect().size.y - map_height_pixels) / 2
	
func unlock_section(which_section: int = sections_crossed) -> void:
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.column == which_section:
			map_room.available = true
			
func unlock_next_rooms() -> void:
	for map_room: MapRoom in rooms.get_children():
		if last_room.next_rooms.has(map_room.room):
			map_room.available = true
	
func show_map() -> void:
	show()
	camera_2d.enabled = true
	
func hide_map() -> void:
	hide()
	camera_2d.enabled = false

func _spawn_room(room: Room) -> void:
	var new_map_room := MAP_ROOM.instantiate() as MapRoom
	rooms.add_child(new_map_room)
	new_map_room.room = room
	new_map_room.selected.connect(_on_map_room_selected)
	_connect_lines(room)
	
	if room.selected and room.column < sections_crossed:
		new_map_room.show_selected()

func _connect_lines(room: Room) -> void:
	if room.next_rooms.is_empty():
		return
	
	for next: Room in room.next_rooms:
		var new_map_line := MAP_LINE.instantiate() as Line2D
		new_map_line.add_point(room.position)
		new_map_line.add_point(next.position)
		lines.add_child(new_map_line)

func _on_map_room_selected(room: Room) -> void:
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.column == room.column:
			map_room.available = false
			
	last_room = room
	sections_crossed += 1
	GameEventHandler.map_exited.emit(room)
