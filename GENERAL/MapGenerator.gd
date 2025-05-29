extends Node
class_name MapGenerator

## map_rng is the RandomNumberGenerator for the map. This should be consistent if the seed is the same.
var map_rng = RandomnessManager.map_rng

const SECTIONS := 15
const MAP_HEIGHT := 7
const PATHS := 6
const X_DIST := 80
const Y_DIST := 80
const PLACEMENT_VARIANCE := 15
const MONSTER_ROOM_WEIGHT := 8.0
const ELITE_ROOM_WEIGHT := 3.0
const SHOP_ROOM_WEIGHT := 2.0
const REST_ROOM_WEIGHT := 2.0
const TREASURE_ROOM_WEIGHT := 1.0
const LIBRARY_ROOM_WEIGHT := 1.0
const RANDOM_ROOM_WEIGHT := 14.0

var random_room_type_weights = {
	Room.RoomType.MONSTER: 0.0,
	Room.RoomType.ELITE: 0.0,
	Room.RoomType.REST: 0.0,
	Room.RoomType.SHOP: 0.0,
	Room.RoomType.TREASURE: 0.0,
	Room.RoomType.LIBRARY: 0.0,
	Room.RoomType.RANDOM: 0.0
}

var random_room_type_total_weight := 0

var map_data: Array[Array]

func _ready() -> void:
	RandomnessManager._set_rng_seed(hash("Testing Seed"))
	generate_map()


func generate_map() -> Array[Array]:
	map_data = _generate_initial_grid()
	var starting_points := _get_random_starting_points()
	
	for j in starting_points:
		var current_j := j
		
		for i in SECTIONS - 1:
			current_j = _setup_connection(i, current_j)
			
	_setup_boss_room()
	_setup_center_rest_site()
	_setup_random_room_weights()
	_setup_room_types()
	
	return map_data

func _generate_initial_grid() -> Array[Array]:
	var result: Array[Array] = []
	
	for i in SECTIONS:
		var adjacent_rooms: Array[Room] = []
		
		for j in MAP_HEIGHT:
			var current_room := Room.new()
			var offset := Vector2(map_rng.randf(), map_rng.randf()) * PLACEMENT_VARIANCE
			current_room.position = Vector2(i * X_DIST, j * Y_DIST) + offset
			if i == 7:
				j = 3

			current_room.row = j
			current_room.column = i
			current_room.next_rooms = []

			if i == floori(SECTIONS * 0.5):
				current_room.position.x = (i + 1) * X_DIST

			if i > floori(SECTIONS * 0.5):
				current_room.position.x = (i + 2) * X_DIST

			# Rest site just prior to the boss has a non-random position
			if i == SECTIONS - 2:
				current_room.position.x = (i + 2) * X_DIST
	
			# Boss room has a non-random position.
			if i == SECTIONS - 1:
				current_room.position.x = (i + 3) * X_DIST
			
			if i == 7:
				j = 7
			
			adjacent_rooms.append(current_room)
			
		result.append(adjacent_rooms)
	
	return result

func _get_random_starting_points() -> Array[int]:
	var y_coordinates: Array[int]
	var unique_points: int = 0
	
	while unique_points < 2:
		unique_points = 0
		y_coordinates = []
		
		for i in PATHS:
			var starting_point := map_rng.randi_range(0, MAP_HEIGHT - 1)
			if not y_coordinates.has(starting_point):
				unique_points += 1
		
			y_coordinates.append(starting_point)
				
	return y_coordinates

func _setup_connection(i: int, j: int) -> int:
	var next_room: Room
	var current_room := map_data[i][j] as Room
	
	if i == 7:
		while not next_room:
			var random_j := clampi(map_rng.randi_range(j - 3, j + 3), 0, MAP_HEIGHT - 1)
			next_room = map_data[i + 1][random_j]
	
	else:
		while not next_room or _would_cross_existing_path(i, j, next_room):
			var random_j := clampi(map_rng.randi_range(j - 1, j + 1), 0, MAP_HEIGHT - 1)
			next_room = map_data[i + 1][random_j]
		
	current_room.next_rooms.append(next_room)
	
	return next_room.row
	
func _would_cross_existing_path(i: int, j: int, room: Room) -> bool:
	var upper_neighbor: Room
	var lower_neighbor: Room
	
	# if j == 0, there can't be a upper neighbor.
	if j > 0:
		upper_neighbor = map_data[i][j - 1]
	
	# if j == MAP_HEIGHT - 1, there's no lower neighbor
	if j < MAP_HEIGHT - 1:
		lower_neighbor = map_data[i][j + 1]

	if lower_neighbor and room.row > j:
		for next_room: Room in lower_neighbor.next_rooms:
			if next_room.row < room.row:
				return true
	
	if upper_neighbor and room.row < j:
		for next_room: Room in upper_neighbor.next_rooms:
			if next_room.row > room.row:
				return true
	
	return false
	
func _setup_boss_room() -> void:
	var middle := floori(MAP_HEIGHT * 0.5)
	var boss_room := map_data[SECTIONS - 1][middle] as Room

	for j in MAP_HEIGHT:
		var current_room = map_data[SECTIONS - 2][j] as Room
		if current_room.next_rooms:
			current_room.next_rooms = [] as Array[Room]
			current_room.next_rooms.append(boss_room)
	
	boss_room.type = Room.RoomType.BOSS

func _setup_center_rest_site() -> void:
	var middle_row := floori(MAP_HEIGHT * 0.5)
	var middle_column := floori(SECTIONS * 0.5)
	var rest_site := map_data[middle_column][middle_row] as Room
	
	for j in MAP_HEIGHT:
		var current_room = map_data[middle_column-1][j] as Room
		if current_room.next_rooms:
			current_room.next_rooms = [] as Array[Room]
			current_room.next_rooms.append(rest_site)
	
	rest_site.type = Room.RoomType.REST

func _setup_random_room_weights() -> void:

	random_room_type_weights[Room.RoomType.MONSTER] = MONSTER_ROOM_WEIGHT
	random_room_type_weights[Room.RoomType.ELITE] = MONSTER_ROOM_WEIGHT + ELITE_ROOM_WEIGHT
	random_room_type_weights[Room.RoomType.REST] = MONSTER_ROOM_WEIGHT + ELITE_ROOM_WEIGHT + REST_ROOM_WEIGHT
	random_room_type_weights[Room.RoomType.SHOP] = MONSTER_ROOM_WEIGHT + ELITE_ROOM_WEIGHT + REST_ROOM_WEIGHT + SHOP_ROOM_WEIGHT
	random_room_type_weights[Room.RoomType.TREASURE] = MONSTER_ROOM_WEIGHT + ELITE_ROOM_WEIGHT + REST_ROOM_WEIGHT + SHOP_ROOM_WEIGHT + TREASURE_ROOM_WEIGHT
	random_room_type_weights[Room.RoomType.LIBRARY] = MONSTER_ROOM_WEIGHT + ELITE_ROOM_WEIGHT + REST_ROOM_WEIGHT + SHOP_ROOM_WEIGHT + TREASURE_ROOM_WEIGHT + LIBRARY_ROOM_WEIGHT
	random_room_type_weights[Room.RoomType.RANDOM] = MONSTER_ROOM_WEIGHT + ELITE_ROOM_WEIGHT + REST_ROOM_WEIGHT + SHOP_ROOM_WEIGHT + TREASURE_ROOM_WEIGHT + LIBRARY_ROOM_WEIGHT + RANDOM_ROOM_WEIGHT
	
	random_room_type_total_weight = random_room_type_weights[Room.RoomType.RANDOM]
	
func _setup_room_types() -> void:
	var middle_row := floori(MAP_HEIGHT * 0.5)
	var middle_column := floori(SECTIONS * 0.5)
	
	# First section is always combat.
	for room: Room in map_data[0]:
		if room.next_rooms.size() > 0:
			room.type = Room.RoomType.MONSTER
			
	# Seventh section is always Treasure (67%) or Library (33%).
	for room: Room in map_data[middle_column - 1]:
		var random_roll = map_rng.randf()
		if room.next_rooms.size() > 0 and random_roll <= 0.67:
			room.type = Room.RoomType.TREASURE
		elif room.next_rooms.size() > 0 and random_roll > 0.67:
			room.type = Room.RoomType.LIBRARY
	
	# Eighth section is always Rest
	for room: Room in map_data[middle_column]:
		if room.next_rooms.size() > 0:
			room.type = Room.RoomType.REST
	
	# Penultimate section is always Rest
	for room: Room in map_data[SECTIONS - 2]:
		if room.next_rooms.size() > 0:
			room.type = Room.RoomType.REST
		
	for current_floor in map_data:
		for room: Room in current_floor:
			for next_room: Room in room.next_rooms:
				if next_room.type == Room.RoomType.UNASSIGNED:
					_set_room_randomly(next_room)
					
func _set_room_randomly(room_to_set: Room) -> void:
	
	var rest_below_4 			:= true
	var elite_below_4			:= true
	var consecutive_rest 		:= true
	var consecutive_shop 		:= true
	var consecutive_reliquary 	:= true
	var consecutive_elite		:= true
	var reliquary_below_7 		:= true
	var rest_on_9				:= true
	var rest_on_13 				:= true
	
	var type_candidate: Room.RoomType
	
	while rest_below_4 or elite_below_4 or consecutive_rest or consecutive_shop or consecutive_reliquary or consecutive_elite or reliquary_below_7 or rest_on_9 or rest_on_13:
		type_candidate = _get_random_room_type_by_weight()
		
		var is_rest := type_candidate == Room.RoomType.REST
		var has_rest_parent := _room_has_parent_of_type(room_to_set, Room.RoomType.REST)
		
		var is_shop := type_candidate == Room.RoomType.SHOP
		var has_shop_parent := _room_has_parent_of_type(room_to_set, Room.RoomType.SHOP)
		
		var is_reliquary := (type_candidate == Room.RoomType.TREASURE or type_candidate == Room.RoomType.LIBRARY)
		var has_treasure_parent := _room_has_parent_of_type(room_to_set, Room.RoomType.TREASURE)
		var has_library_parent := _room_has_parent_of_type(room_to_set, Room.RoomType.LIBRARY)
		
		var is_elite := type_candidate == Room.RoomType.ELITE
		var has_elite_parent := _room_has_parent_of_type(room_to_set, Room.RoomType.ELITE)
		
		rest_below_4 = is_rest and room_to_set.column < 3
		elite_below_4 = is_elite and room_to_set.column < 3
		reliquary_below_7 = is_reliquary and room_to_set.column < 6
		consecutive_rest = is_rest and has_rest_parent
		consecutive_shop = is_shop and has_shop_parent
		consecutive_reliquary = is_reliquary and (has_treasure_parent or has_library_parent)
		consecutive_elite = is_elite and has_elite_parent
		rest_on_9 = is_rest and room_to_set.column == 8
		rest_on_13 = is_rest and room_to_set.column == 12
		
	room_to_set.type = type_candidate
	

func _room_has_parent_of_type(room: Room, type: Room.RoomType) -> bool:
	var parents: Array[Room] = []
	var middle_row := floori(MAP_HEIGHT * 0.5)
	var middle_column := floori(SECTIONS * 0.5)

	if not room.column == middle_column:
		# Upper Parent
		if room.row > 0 and room.column > 0:
			var parent_candidate := map_data[room.column - 1][room.row - 1] as Room
			if parent_candidate.next_rooms.has(room):
				parents.append(parent_candidate)
				
		# Previous parent Parent
		if room.column > 0:
			var parent_candidate := map_data[room.column - 1][room.row] as Room
			if parent_candidate.next_rooms.has(room):
				parents.append(parent_candidate)
		
		# Lower Parent
		if room.row < MAP_HEIGHT - 1 and room.column > 0:
			var parent_candidate := map_data[room.column - 1][room.row + 1] as Room
			if parent_candidate.next_rooms.has(room):
				parents.append(parent_candidate)
		
		for parent: Room in parents:
			if parent.type == type:
				return true
	
	elif room.column == middle_column:
		# Upper Parent
		if room.row > 0 and room.column > 0:
			var parent_candidate := map_data[room.column - 1][room.row - 3] as Room
			if parent_candidate.next_rooms.has(room):
				parents.append(parent_candidate)
				
		# Previous parent Parent
		if room.column > 0:
			var parent_candidate := map_data[room.column - 1][room.row] as Room
			if parent_candidate.next_rooms.has(room):
				parents.append(parent_candidate)
		
		# Lower Parent
		if room.row < MAP_HEIGHT - 1 and room.column > 0:
			var parent_candidate := map_data[room.column - 1][room.row + 3] as Room
			if parent_candidate.next_rooms.has(room):
				parents.append(parent_candidate)
	
	return false
	
func _get_random_room_type_by_weight() -> Room.RoomType:
	var roll := map_rng.randf_range(0.0, random_room_type_total_weight)
	for type: Room.RoomType in random_room_type_weights:
		if random_room_type_weights[type] > roll:
			return type
			
	return Room.RoomType.MONSTER
