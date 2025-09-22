extends Node2D
class_name NewMapHandler

var map_rng = RandomnessManager.map_rng

const NEW_MAP = preload("res://GENERAL/GAME_SCENES/MAP/NewMap.tscn")

var map_scene: NewMap

# Columns is our X value, Rows is our Y value
const COLUMNS := 16
const ROWS := 7

# Number of attempted starting paths
const PATHS := 6

# Distance X/Y between map nodes. Can be added to.
const X_DIST := 60
const Y_DIST := 45

# Placement variance for map nodes
const PLACEMENT_VARIANCE := 10

const room_type_weights = [11.0, 3.0, 2.0, 1.0, 1.0, 1.0, 11.0]

var random_room_type_weights = {
	Room.RoomType.MONSTER:		0.0,
	Room.RoomType.ELITE:		0.0,
	Room.RoomType.SHOP:			0.0,
	Room.RoomType.REST:			0.0,
	Room.RoomType.TREASURE:		0.0,
	Room.RoomType.LIBRARY:		0.0,
	Room.RoomType.RANDOM:		0.0
}

var room_type_weight_total := 0.0

## We're going to make a 16 x 7 matrix.
## The first column is ALWAYS combat.
## The seventh column is always a Reliquary or Library, and all of them connect to eight.
## The eigth column is always a Rest, and all of them connect to stands starting at nine.
## The fifteenth column is always a Rest, and all of them connect to sixteen.
var map_data: Array[Array]

var starting_points: Array[int]

var sections_crossed: int
var last_room: Room

var set_unlock_section: bool

var last_camera_position: float = 0.0

func _ready() -> void:
	pass # Replace with function body.

func generate_map() -> Array[Array]:
	map_data = _generate_initial_grid()
	starting_points = _generate_starting_points()
	starting_points.sort()
	
	for y in starting_points:
		var current_y := y
		
		for x in COLUMNS - 1:
			current_y = _create_strands(x, current_y)
	
	_setup_boss_room()
	_setup_center_rest_site()
	_setup_room_weights()
	_setup_room_types()

	return map_data
func _generate_initial_grid():
	var result: Array[Array] = []
	
	for x in COLUMNS:
		var adjacent_rooms: Array[Room] = []
		
		for y in ROWS:
			var current_room := Room.new()
			var offset := Vector2(map_rng.randf(), map_rng.randf()) * PLACEMENT_VARIANCE
			current_room.position = Vector2(x * X_DIST, y * Y_DIST) + offset
			current_room.offset = offset
			
			if x == 7:
				y = 3
			current_room.column = x
			current_room.row = y
			if x == 7:
				y = 7
			
			# Nodes prior to guaranteed Reliquaries
			if x < 6:
				current_room.position.x = (x) * X_DIST + current_room.offset.x
				current_room.position.y = y * Y_DIST + current_room.offset.y
			
			# Pre-Midpoint Reliquaries
			if x == 6:
				current_room.position.x = (x) * X_DIST
				current_room.position.y = y * Y_DIST
			
			# mid-Chapter Rest Site
			if x == 7:
				current_room.position.x = (x + 1) * X_DIST
				current_room.position.y = 3 * Y_DIST
			
			# Post-Midpoint Node
			if x == 8:
				current_room.position.x = (x + 2) * X_DIST
				current_room.position.y = y * Y_DIST
			
			# Post-Post Midpoint Node
			if x > 8:
				current_room.position.x = (x + 2) * X_DIST + current_room.offset.x
				current_room.position.y = y * Y_DIST + current_room.offset.y
			
			# Pre-Boss Rest Site
			if x == 14:
				current_room.position.x = (x + 2) * X_DIST
				current_room.position.y = y * Y_DIST
			
			# Boss Location
			if x == 15:
				current_room.position.x = (x + 3) * X_DIST
				current_room.position.y = 3 * Y_DIST
				
			adjacent_rooms.append(current_room)
			
		result.append(adjacent_rooms)
	
	return result
func _generate_starting_points() -> Array[int]:
	var y_coordinates: Array[int]
	var unique_points: int = 0
	
	while unique_points < 2:
		unique_points = 0
		y_coordinates = []
		
		for y in PATHS:
			var starting_point := (map_rng.randi_range(1, ROWS) - 1)
			if not y_coordinates.has(starting_point):
				unique_points += 1
			
			y_coordinates.append(starting_point)

	return y_coordinates
func _create_strands(x: int, y: int) -> int:
	var next_room: Room = null
	var current_room = map_data[x][y] as Room
	
	if x == 7 or x == 14:
		while not next_room:
			var random_y = clampi(map_rng.randi_range(y-3, y+3), 0, 6)
			next_room = map_data[x+1][random_y]
			if not next_room.previous_rooms.has(current_room):
				next_room.previous_rooms.append(current_room)
	
	else:
		while not next_room or _would_cross_paths(x, y, next_room):
			var random_y = clampi(map_rng.randi_range(y-1, y+1), 0, 6)
			next_room = map_data[x+1][random_y]
			
	current_room.next_rooms.append(next_room)
	if not next_room.previous_rooms.has(current_room):
		next_room.previous_rooms.append(current_room)
	
	return next_room.row
func _would_cross_paths(x: int, y: int, room: Room) -> bool:
	var upper_neighbor: Room
	var lower_neighbor: Room
	
	# if j == 0, there can't be a upper neighbor.
	if y > 0:
		upper_neighbor = map_data[x][y - 1]
	
	# if j == MAP_HEIGHT - 1, there's no lower neighbor
	if y < 6:
		lower_neighbor = map_data[x][y + 1]

	if lower_neighbor and room.row > y:
		for next_room: Room in lower_neighbor.next_rooms:
			if next_room.row < room.row:
				return true
	
	if upper_neighbor and room.row < y:
		for next_room: Room in upper_neighbor.next_rooms:
			if next_room.row > room.row:
				return true
	
	return false

func _setup_center_rest_site() -> void:
	var rest_site := map_data[7][3] as Room
	
	for y in ROWS:
		var current_room = map_data[6][y] as Room
		if current_room.next_rooms:
			current_room.next_rooms = [] as Array[Room]
			current_room.next_rooms.append(rest_site)
			rest_site.previous_rooms.append(current_room)
			
	rest_site.type = Room.RoomType.REST
func _setup_boss_room() -> void:
	var boss_room := map_data[15][3] as Room
	
	for y in ROWS:
		var current_room = map_data[14][y] as Room
		if current_room.next_rooms:
			current_room.next_rooms = [] as Array[Room]
			current_room.next_rooms.append(boss_room)
			boss_room.previous_rooms.append(current_room)
			
	boss_room.type = Room.RoomType.BOSS
func _setup_room_types() -> void:
	
	# First section is always combat.
	for room: Room in map_data[0]:
		if room.next_rooms.size() > 0:
			room.type = Room.RoomType.MONSTER
	
	# Seventh section is always Treasure (67%) or Library (33%).
	for room: Room in map_data[6]:
		var random_roll = map_rng.randf()
		if room.next_rooms.size() > 0 and random_roll <= float(2.0/3.0):
			room.type = Room.RoomType.TREASURE
		elif room.next_rooms.size() > 0:
			room.type = Room.RoomType.LIBRARY
	
	# Penultimate section is always Rest
	for room: Room in map_data[14]:
		if room.next_rooms.size() > 0:
			room.type = Room.RoomType.REST
			
	for current_section in map_data:
		for room: Room in current_section:
			for next_room: Room in room.next_rooms:
				if next_room.type == Room.RoomType.UNASSIGNED:
					_set_room_randomly(next_room)
func _set_room_randomly(room: Room) -> void:
	
	var type_candidate: Room.RoomType
	
	while room.type == Room.RoomType.UNASSIGNED:
		type_candidate = _get_type_by_weight()
		
		if room.column < 3 and (type_candidate == Room.RoomType.ELITE or type_candidate == Room.RoomType.REST):
			continue
		
		if room.column < 6 and (type_candidate == Room.RoomType.TREASURE or type_candidate == Room.RoomType.LIBRARY):
			continue
		
		if _consecutive_room_type(room, type_candidate):
			continue
			
		if type_candidate == Room.RoomType.RANDOM and _triple_room(room, type_candidate):
			continue
		
		#elif _quad_room(room, type_candidate):
			#continue
		
		if (room.column == 8 or room.column == 14) and type_candidate == Room.RoomType.REST:
			continue
		
		else:
			room.type = type_candidate
			
func _get_type_by_weight():
	var roll := map_rng.randf_range(0.0, room_type_weight_total)
	for type: Room.RoomType in random_room_type_weights:
		if random_room_type_weights[type] > roll:
			return type
			
	return Room.RoomType.MONSTER
func _consecutive_room_type(room: Room, type_candidate: Room.RoomType):
	for past_room in room.previous_rooms:
		if type_candidate == Room.RoomType.ELITE or type_candidate == Room.RoomType.REST \
		or type_candidate == Room.RoomType.TREASURE or type_candidate == Room.RoomType.LIBRARY \
		or type_candidate == Room.RoomType.SHOP:
			if past_room.type == type_candidate:
				return true
				
		else:
			return false
func _triple_room(room: Room, type_candidate: Room.RoomType):
	
	var layer_1 = false
	var layer_2 = false
	var layer_3 = false
	
	for past_room in room.previous_rooms:
		if room.previous_rooms.size() > 0:
			if past_room.type == type_candidate:
				layer_1 = true
				for second_layer in past_room.previous_rooms:
					if second_layer.previous_rooms.size() > 0:
						if second_layer.type == type_candidate:
							layer_2 = true
							for third_layer in second_layer.previous_rooms:
								if third_layer.previous_rooms.size() > 0:
									if third_layer.type == type_candidate:
										layer_3 = true
	
	if layer_1 and layer_2 and layer_3:
		return true
		
	else:
		return false

func _setup_room_weights():
	for weight in room_type_weights:
		var key = random_room_type_weights.find_key(0.0)
		room_type_weight_total += weight
		random_room_type_weights[key] = room_type_weight_total

func _on_new_map_button_toggled(_toggled_on: bool) -> void:
	if GeneralManager.is_map_open == false:
		print("Map opening!")
		GeneralManager.is_map_open = true
		%NewMapButton.set_disabled(true)
		map_scene = NEW_MAP.instantiate()
		%MapParent.add_child(map_scene)
		await map_scene._on_map_bringup(map_data, last_camera_position)
		if set_unlock_section:
			map_scene.unlock_section(sections_crossed)
		%NewMapButton.set_disabled(false)
		
	elif GeneralManager.is_map_open == true:
		print("Map closing!")
		%NewMapButton.set_disabled(true)
		map_scene.perform_map_shutdown_procedure()
		await get_tree().create_timer(0.75).timeout
		GeneralManager.is_map_open = false
		%NewMapButton.set_disabled(false)

func _force_open_map():
	if GeneralManager.is_map_open == false:
		print("Map opening!")
		GeneralManager.is_map_open = true
		%NewMapButton.set_disabled(true)
		%NewMapButton.set_pressed_no_signal(true)
		map_scene = NEW_MAP.instantiate()
		%MapParent.add_child(map_scene)
		await map_scene._on_map_bringup(map_data, last_camera_position)
		if set_unlock_section:
				map_scene.unlock_section(sections_crossed)
		%NewMapButton.set_disabled(false)
	
	return map_scene

func _force_close_map():
	if GeneralManager.is_map_open == true:
		print("Map closing!")
		%NewMapButton.set_disabled(true)
		map_scene.perform_map_shutdown_procedure()
		await get_tree().create_timer(0.75).timeout
		GeneralManager.is_map_open = false
		%NewMapButton.set_disabled(false)
		%NewMapButton.set_pressed_no_signal(false)

func _unlock_map_section(section: int) -> void:
	await _force_open_map()
	map_scene.unlock_section(section)
	set_unlock_section = true

func _unlock_next_map_rooms() -> void:
	await _force_open_map()
	map_scene.unlock_next_rooms()
	set_unlock_section = true

func _on_run_start():
	_unlock_map_section(0)
