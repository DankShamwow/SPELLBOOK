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

var reward_gold_button
var reward_notch_button
var reward_relic_button

var first_click = false

@export var fade_in_mask: ColorRect
@export var button_container: VBoxContainer
@export var reward_gold_button_icon: Texture2D
@export var reward_notch_button_icon: Texture2D

var notches = []
var draws = []
var tiles = []

signal tile_tooltip_requested(which)
signal tile_tooltip_hide_requested()

signal notch_tooltip_requested(which)
signal notch_tooltip_hide_requested()

#func _ready() -> void:
	#for i in starting_bag.size():
		#current_deck.append(starting_bag[i])
		#available_tiles.append(current_deck[i])
	#
	#var tween = self.create_tween()
	#tween.tween_property(self, "modulate:a", 0, 0.001)
	#tween.tween_property(self, "visible", true, 0.001)
	#tween.tween_property(self, "modulate:a", 1, 0.15)
	#
	#query_combat_rewards(50, 15, 0)

func _bringup_combat_rewards(reward_gold: int, reward_notch_count: int, reward_relics: int):
	
	for i in current_deck.size():
		available_tiles.append(current_deck[i])
	
	var tween = self.create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.001)
	tween.tween_property(self, "visible", true, 0.001)
	tween.tween_property(self, "modulate:a", 1, 0.15)
	
	query_combat_rewards(reward_gold, reward_notch_count, reward_relics)

func _is_tile_hovered(which: GridTile, is_hovering: bool):
	if is_hovering == true:
		which.hovering = is_hovering
		tile_tooltip_requested.emit(which)
	
	if is_hovering == false:
		which.hovering = is_hovering
		tile_tooltip_hide_requested.emit()
		
func _is_notch_hovered(which: NotchObject, is_hovering: bool):
	if is_hovering == true:
		notch_tooltip_requested.emit(which)
		
	if is_hovering == false:
		notch_tooltip_hide_requested.emit()


func query_combat_rewards(reward_gold: int, reward_notch_count: int, reward_relics: int):
	if reward_gold > 0:
		reward_gold_button = Button.new()
		button_container.add_child(reward_gold_button)
		var gold_button_text_string = str(reward_gold) + " gold"
		reward_gold_button.text = gold_button_text_string
		
		if reward_gold < 50:
			reward_gold_button_icon.region = Rect2(0, 0, 32, 32)
		
		elif reward_gold >= 50 and reward_gold < 100:
			reward_gold_button_icon.region = Rect2(32, 0, 32, 32)
			
		elif reward_gold >= 100 and reward_gold < 250:
			reward_gold_button_icon.region = Rect2(64, 0, 32, 32)
			
		else:
			reward_gold_button_icon.region = Rect2(96, 0, 32, 32)
			
		reward_gold_button.set_button_icon(reward_gold_button_icon)
		reward_gold_button.pressed.connect(self._on_reward_gold_button_pressed)
		
	if reward_notch_count > 0:
		set_notch_reward_rng(reward_notch_count)
		reward_notch_button = Button.new()
		button_container.add_child(reward_notch_button)
		var notch_button_text_string = "Choose " + str(reward_notch_count) + " notches"
		reward_notch_button.text = notch_button_text_string
		reward_notch_button.set_button_icon(reward_notch_button_icon)
		reward_notch_button.pressed.connect(self._on_reward_notch_button_pressed)
		
	if reward_relics > 0:
		for i in reward_relics:
			reward_relic_button = Button.new()
			button_container.add_child(reward_relic_button)
			reward_relic_button.pressed.connect(self._on_reward_relic_button_pressed)
		
func _on_reward_gold_button_pressed():
	if not reward_gold_button == null:
		reward_gold_button.queue_free()
	
	await get_tree().create_timer(0.05).timeout
	
	if button_container.get_child_count() == 0:
		%RewardsSkipButtonLabel.text = str("PROCEED")

func _on_reward_notch_button_pressed():
	if not reward_notch_button == null and %RewardsButtonList.visible == true:
		var tween = %RewardsButtonList.create_tween()
		tween.tween_property(%RewardsButtonList, "modulate:a", 0, 0.15)
		tween.tween_property(%RewardsButtonList, "visible", false, 0.001)
		populate_notches_draws_and_tiles(notches, draws, tiles)

func _on_reward_relic_button_pressed():
	if button_container.get_child_count() == 0:
		await get_tree().create_timer(0.05).timeout
		%RewardsSkipButtonLabel.text = str("PROCEED")

# INFO: It is safe to call this multiple times, as this only populates the UI that appears when you click the notch reward button.
func populate_notches_draws_and_tiles(notches: Array, draws: Array, tiles: Array):
	var tween = %NotchAndTileRewardParent.create_tween()
	tween.tween_property(%NotchAndTileRewardParent, "modulate:a", 0, 0.001)
	tween.tween_property(%NotchAndTileRewardParent, "visible", true, 0.001)
	tween.tween_property(%NotchAndTileRewardParent, "modulate:a", 1, 0.15)
	await get_tree().create_timer(0.5).timeout
	var new_home_pose = Vector2(0, 0)
	var previous_starting_pose = Vector2(0, 0)
	var pose_spacing = 150.0 / notches.size()
	if first_click == false:
		first_click = true
		for i in notches.size():
			var new_notch = NOTCH_OBJECT_SCENE.instantiate()
			new_notch.notch = notches[i]
			%NotchesParent.add_child(new_notch)
			new_notch.update_tooltip.connect(%StickyTileTooltip._show_tooltip)
			new_notch.notch_hovered.connect(self._is_notch_hovered)
			var notch_tween = new_notch.create_tween()
			notch_tween.tween_property(new_notch, "modulate:a", 0, 0.001)
			notch_tween.tween_property(new_notch, "modulate:a", 1, 0.15)
			if i == 0:
				new_home_pose = Vector2(various_rng.randi_range(192, 212), various_rng.randi_range(144, 168))
				previous_starting_pose = new_home_pose
			
			else:
				new_home_pose = Vector2(various_rng.randi_range(previous_starting_pose.x + (pose_spacing),  previous_starting_pose.x + (1.95 * pose_spacing)), various_rng.randi_range(144, 168))
				previous_starting_pose = new_home_pose
				
			var starting_rot = various_rng.randi_range(-22.5, 22.5)
			new_notch.global_position = new_home_pose
			new_notch.home_pose = new_home_pose
			new_notch.rotation_degrees = starting_rot
			
		for i in draws.size():
			print("Drawing new tile!")
			var new_tile = GRID_TILE_SCENE.instantiate()
			new_tile.tile = current_deck[draws[i]]
			%PlayerTilesParent.add_child(new_tile)
			new_tile.tile_clicked.connect(self._on_tile_clicked)
			new_tile.tile_hovered.connect(self._is_tile_hovered)
			new_tile.toggle_monitorable()
			new_tile.position = Vector2(592, 32)
			new_tile.tile.target = Vector2(64+(80*i), (232 + (((i+1) % 2) * 48)))
			new_tile.spawned_from_bag()
			new_tile.move_to_position(0.5)
			new_tile.play_tile_sound()
			await get_tree().create_timer(0.1).timeout

		for i in tiles.size():
			print("Cooking new tile!")
			var new_tile = GRID_TILE_SCENE.instantiate()
			new_tile.tile = tiles[i]
			%NewTilesParent.add_child(new_tile)
			new_tile.tile_clicked.connect(self._on_tile_clicked)
			new_tile.tile_hovered.connect(self._is_tile_hovered)
			new_tile.position = Vector2(208 + (48 * i), 416)
			new_tile.spawned_from_bag()

# WARNING: ONLY CALL THIS ONCE PER COMBAT REWARD. DO NOT CALL THIS MULTIPLE TIMES OTHERWISE IT WILL REPLACE THE LOOT.
func set_notch_reward_rng(notch_count: int):
	var letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
	for i in notch_count:
		# REMEMBER NITWIT, YOU GOTTA SUBTRACT ONE BECAUSE IT'S AN ARRAY AND IT STARTS AT ZERO.
		var notch_type_roll = reward_rng.randi() % 20
		#var notch_type_roll = 19
		var notch_letter_roll = ""
		if notch_type_roll == 19:
			notch_letter_roll = reward_rng.randi() % 25
			notch_letter_roll = letters[notch_letter_roll]
			
		var new_notch = Notch.new().new_notch(notch_type_roll, notch_letter_roll)
		notches.append(new_notch)
		
	# Twice the number of notches - 1 is the option number, lower limit of 3, upper limit of 7.
	var draw_limit = ((notch_count * 2) - 1)
	
	if draw_limit < 3:
			draw_limit = 3
	
	if draw_limit > 7:
			draw_limit = 7
	
	for i in draw_limit:
		var pop_location = (tile_rng.randi() % available_tiles.size())
		draws.append(available_tiles[pop_location].tile_index)
		available_tiles.pop_at(pop_location)
		print(pop_location)
		print(draws)

	for i in 5:
		var type = 0
		var letter = reward_rng.randi() % 25
		# REMEMBER NITWIT, YOU GOTTA SUBTRACT TWO BECAUSE IT'S AN ARRAY AND IT STARTS AT ZERO, AND YOU DON'T WANT THESE HAVING BONUS LETTERS.
		var notch1 = reward_rng.randi_range(1, 18)
		var notch2 = 0
		var notch3 = 0
		
		var new_tile = LetterTile.new().generate_tile(type, letter, notch1, notch2, notch3)
		tiles.append(new_tile)

func _on_tile_clicked(which: GridTile, action: GridTile.GridTileAction):
	if which.get_parent() == %NewTilesParent:
		if action == GridTile.GridTileAction.PLAY:
			
			if which.is_in_group("Tiles to Add"):
				which.remove_from_group("Tiles to Add")
				which.tile.target = Vector2(which.position.x, 416)
				which.move_to_position()
			
			elif not which.is_in_group("Tiles to Add"):
				which.add_to_group("Tiles to Add")
				which.tile.target = Vector2(which.position.x, 400)
				which.move_to_position()

func _on_skip_button_pressed() -> void:
	if %NotchAndTileRewardParent.visible == true:
		var tween = %NotchAndTileRewardParent.create_tween()
		tween.tween_property(%NotchAndTileRewardParent, "modulate:a", 0, 0.15)
		tween.tween_property(%NotchAndTileRewardParent, "visible", false, 0.001)
	
		var tween2 = %RewardsButtonList.create_tween()
		tween2.tween_property(%RewardsButtonList, "visible", true, 0.001)
		tween2.tween_property(%RewardsButtonList, "modulate:a", 1, 0.15)
	
	await get_tree().create_timer(0.15).timeout
	
	for notch in %NotchesParent.get_children():
		notch._force_home()
		
	for tile in %NewTilesParent.get_children():
		if tile.is_in_group("Tiles to Add"):
			tile.remove_from_group("Tiles to Add")
			tile.tile.target = Vector2(tile.position.x, 416)
			tile.move_to_position()

func _on_confirm_button_pressed() -> void:
	%ConfirmButton.set_disabled(true)
	if %NotchAndTileRewardParent.visible == true:
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
				
			for notch in %NotchesParent.get_children():
				if notch.paired_tile == null:
					var notch_tween = notch.create_tween()
					notch_tween.tween_property(notch, "modulate:a", 0, 0.05)
					await get_tree().create_timer(0.06).timeout
					notch.queue_free()
				
			for i in has_paired_tile.size():
				var paired_tile = has_paired_tile[i].paired_tile
				var tile_to_modify = current_deck[paired_tile.tile.tile_index]
				var active_notch = has_paired_tile[i]
				
				if active_notch.has_affected_notch1 == true:
					tile_to_modify.notch1 = LetterTile.NotchTypes[Notch.NotchTypes.keys()[active_notch.notch.type]]
				elif active_notch.has_affected_notch2 == true:
					tile_to_modify.notch2 = LetterTile.NotchTypes[Notch.NotchTypes.keys()[active_notch.notch.type]]
				elif active_notch.has_affected_notch3 == true:
					tile_to_modify.notch3 = LetterTile.NotchTypes[Notch.NotchTypes.keys()[active_notch.notch.type]]
				
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
			
			for notch in %NotchesParent.get_children():
				if notch.paired_tile == null:
					var notch_tween = notch.create_tween()
					notch_tween.tween_property(notch, "modulate:a", 0, 0.05)
					await get_tree().create_timer(0.06).timeout
					notch.queue_free()
			
			
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
	
			
	var tween = %NotchAndTileRewardParent.create_tween()
	tween.tween_property(%NotchAndTileRewardParent, "modulate:a", 0, 0.15)
	tween.tween_property(%NotchAndTileRewardParent, "visible", false, 0.001)
	
	var tween2 = %RewardsButtonList.create_tween()
	tween2.tween_property(%RewardsButtonList, "visible", true, 0.001)
	tween2.tween_property(%RewardsButtonList, "modulate:a", 1, 0.15)
	
	reward_notch_button.queue_free()
	
	await get_tree().create_timer(0.05).timeout
	
	if button_container.get_child_count() == 0:
		%RewardsSkipButtonLabel.text = str("PROCEED")

func _on_rewards_skip_button_pressed() -> void:
	var tween = self.create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.15)
	tween.tween_property(self, "visible", false, 0.001)
	
	GameEventHandler.combat_exited.emit()
