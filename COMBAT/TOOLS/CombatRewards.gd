extends Control
class_name CombatRewards

const GRID_TILE_SCENE = preload("res://TILE/GRID_TILE/GridTile.tscn")
const NOTCH_OBJECT_SCENE = preload("res://TILE/NOTCHES/NotchObject.tscn")

var tile_rng = RandomnessManager.tile_rng
var reward_rng = RandomnessManager.reward_rng
var various_rng = RandomnessManager.various_rng

var starting_bag = StartingTiles.StartingTileArray
var current_deck = GeneralManager.current_deck
var available_tiles = GeneralManager.available_tiles

var notches = []
var draws = []
var tiles = []


func _ready():
	for i in starting_bag.size():
		current_deck.append(starting_bag[i])
	
	for i in current_deck.size():
		available_tiles.append(current_deck[i])
		
	set_notch_reward_rng(5)
	await get_tree().create_timer(1).timeout
	populate_notches_draws_and_tiles(notches, draws, tiles)

# WARNING: ONLY CALL THIS ONCE PER COMBAT REWARD. DO NOT CALL THIS MULTIPLE TIMES OTHERWISE IT WILL REPLACE THE LOOT.
func set_notch_reward_rng(notch_count: int):
	
	for i in notch_count:
		notches.append(reward_rng.randi() % 10)
		
	# Twice the number of notches - 1 is the option number, lower limit of 3, upper limit of 7.
	var draw_limit = ((notch_count * 2) - 1)
	
	if draw_limit < 3:
		draw_limit = 3
	
	if draw_limit > 7:
		draw_limit = 7
	
	for i in draw_limit:
		draws.append(tile_rng.randi() % available_tiles.size())
		
	for i in 5:
		var type = 0
		var letter = randi() % 26
		var notch1 = randi_range(1, 10)
		var notch2 = 0
		var notch3 = 0
		
		var new_tile = LetterTile.new().generate_tile(type, letter, notch1, notch2, notch3)
		tiles.append(new_tile)

# INFO: It is safe to call this multiple times, as this only populates the UI that appears when you click the notch reward button.
func populate_notches_draws_and_tiles(notches: Array, draws: Array, tiles: Array):
	var new_home_pose = Vector2(0, 0)
	var previous_starting_pose = Vector2(0, 0)
	var pose_spacing = 150.0 / notches.size()
	for i in notches.size():
		var new_notch = NOTCH_OBJECT_SCENE.instantiate()
		new_notch.notch_type = notches[i]
		%NotchesParent.add_child(new_notch)
		
		if i == 0:
			new_home_pose = Vector2(various_rng.randi_range(192, 212), various_rng.randi_range(88, 112))
			previous_starting_pose = new_home_pose
		
		else:
			new_home_pose = Vector2(various_rng.randi_range(previous_starting_pose.x + (pose_spacing),  previous_starting_pose.x + (1.95 * pose_spacing)), various_rng.randi_range(88, 112))
			previous_starting_pose = new_home_pose
			
		var starting_rot = various_rng.randi_range(-22.5, 22.5)
		new_notch.global_position = new_home_pose
		new_notch.home_pose = new_home_pose
		new_notch.rotation_degrees = starting_rot
		
	for i in draws.size():
		print("Cooking new tile!")
		var new_tile = GRID_TILE_SCENE.instantiate()
		new_tile.tile = current_deck[draws[i]]
		%PlayerTilesParent.add_child(new_tile)
		new_tile.toggle_monitorable(true)
		new_tile.position = Vector2(592, 32)
		new_tile.tile.target = Vector2(64+(80*i), (196 + (((i+1) % 2) * 48)))
		new_tile.spawned_from_bag()
		new_tile.move_to_position(0.5)
		await get_tree().create_timer(0.1).timeout

	for i in tiles.size():
		print("Cooking new tile!")
		var new_tile = GRID_TILE_SCENE.instantiate()
		new_tile.tile = tiles[i]
		%NewTilesParent.add_child(new_tile)
		new_tile.position = Vector2(208 + (48 * i), 392)
		new_tile.spawned_from_bag()
		new_tile.tile_clicked.connect(self._on_tile_clicked)

func _on_tile_clicked(which: GridTile, action: GridTile.GridTileAction):
	if which.get_parent() == %NewTilesParent:
		if action == GridTile.GridTileAction.PLAY:
			
			if which.is_in_group("Tiles to Add"):
				which.remove_from_group("Tiles to Add")
				which.tile.target = Vector2(which.position.x, 392)
				which.move_to_position()
			
			elif not which.is_in_group("Tiles to Add"):
				which.add_to_group("Tiles to Add")
				which.tile.target = Vector2(which.position.x, 376)
				which.move_to_position()

func _on_confirm_button_pressed() -> void:
	var has_paired_tile = []
	for notch in %NotchesParent.get_children():
		if not notch.paired_tile == null:
			has_paired_tile.append(notch)
	
	var is_selected_tile = []
	for tile in %NewTilesParent.get_children():
		if tile.is_in_group("Tiles to Add"):
			is_selected_tile.append(tile)
		
	if has_paired_tile.size() == 0 and is_selected_tile.size() == 0:
		var tween = get_tree().create_tween()
		%IndecisivePlayer.size = Vector2(576, 40)
		%IndecisivePlayer.text = "[shake rate=30.0 level=5 connected=1]TRY PRESSING THE SKIP BUTTON.[/shake]"
		tween.tween_property(%IndecisivePlayer, "modulate:a", 1.0, 0.1)
		tween.tween_interval(2.5)
		tween.tween_property(%IndecisivePlayer, "modulate:a", 0.0, 0.1)
		await get_tree().create_timer(2.71).timeout
		%IndecisivePlayer.text = ""
		%IndecisivePlayer.size = Vector2(0, 40)
		
	elif has_paired_tile.size() > 0 and is_selected_tile.size() == 0:
		for i in %NewTilesParent.get_child_count():
			%NewTilesParent.get_child(i).is_dying()
		
		for i in has_paired_tile.size():
			var paired_tile = has_paired_tile[i].paired_tile
			var tile_to_modify = current_deck[paired_tile.tile.tile_index]
			var active_notch = has_paired_tile[i]
			
			if active_notch.has_affected_notch1 == true:
				tile_to_modify.notch1 = LetterTile.NotchTypes[active_notch.NotchTypes.keys()[active_notch.notch_type]]
			elif active_notch.has_affected_notch2 == true:
				tile_to_modify.notch2 = LetterTile.NotchTypes[active_notch.NotchTypes.keys()[active_notch.notch_type]]
			elif active_notch.has_affected_notch3 == true:
				tile_to_modify.notch3 = LetterTile.NotchTypes[active_notch.NotchTypes.keys()[active_notch.notch_type]]
			
			var finished = await has_paired_tile[i].play_pairing_anim()
			
			if finished:
				active_notch.queue_free()
				await get_tree().create_timer(0.15).timeout
		
		for i in %PlayerTilesParent.get_child_count():
			%PlayerTilesParent.get_child(-1).tile.target = Vector2(592, 32)
			%PlayerTilesParent.get_child(-1).move_to_position(0.5)
			%PlayerTilesParent.get_child(-1).is_being_added_to_deck()
			%PlayerTilesParent.get_child(-1).reparent(%TilesToKill)
			await get_tree().create_timer(0.1).timeout

	elif has_paired_tile.size() == 0 and is_selected_tile.size() > 0:
		for i in is_selected_tile.size():
			current_deck.append(is_selected_tile[i].tile)
			is_selected_tile[i].tile.target = Vector2(592, 32)
			is_selected_tile[i].is_being_added_to_deck()
			is_selected_tile[i].move_to_position(0.5)
			is_selected_tile[i].reparent(%TilesToKill)
			await get_tree().create_timer(0.1).timeout
			
	else:
		var tween = get_tree().create_tween()
		%IndecisivePlayer.size = Vector2(576, 40)
		%IndecisivePlayer.text = "[shake rate=30.0 level=5 connected=1]YOU MUST MAKE A CHOICE.[/shake]"
		tween.tween_property(%IndecisivePlayer, "modulate:a", 1.0, 0.1)
		tween.tween_interval(2.5)
		tween.tween_property(%IndecisivePlayer, "modulate:a", 0.0, 0.1)
		await get_tree().create_timer(2.71).timeout
		%IndecisivePlayer.text = ""
		%IndecisivePlayer.size = Vector2(0, 40)
			
			
	_cleanup()

func _cleanup():
	await get_tree().create_timer(0.5).timeout
	for i in %TilesToKill.get_child_count():
		var killed_tile = %TilesToKill.get_child(-1)
		killed_tile.free()
