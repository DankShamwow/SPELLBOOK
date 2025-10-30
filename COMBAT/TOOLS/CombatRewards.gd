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

var common_notch_ids = GeneralManager.common_notch_ids
var uncommon_notch_ids = GeneralManager.uncommon_notch_ids
var rare_notch_ids = GeneralManager.rare_notch_ids
var rare_notch_ids_no_lexical = GeneralManager.rare_notch_ids_no_lexical
var consonant_letter_pool = GeneralManager.consonant_letter_ids
var vowel_letter_pool = GeneralManager.vowel_letter_ids
var rare_consonant_pool = GeneralManager.rare_consonant_pool
var tier_1_lexical_pool = GeneralManager.tier_1_lexical_pool
var tier_2_lexical_pool = GeneralManager.tier_2_lexical_pool
var tier_3_lexical_pool = GeneralManager.tier_3_lexical_pool
var tier_4_lexical_pool = GeneralManager.tier_4_lexical_pool

var reward_gold_button
var reward_notch_button
var reward_relic_button = preload("res://COMBAT/TOOLS/RewardsRelicButton.tscn")

var first_click = false

@export var fade_in_mask: ColorRect
@export var button_container: VBoxContainer
@export var reward_gold_button_icon: Texture2D
@export var reward_notch_button_icon: Texture2D

var notches = []
var draws = []
var tiles = []
var relics = []

func _ready() -> void:
	GameEventHandler.tile_clicked.connect(self._on_tile_clicked)
	GameEventHandler.notch_hovered.connect(self._is_notch_hovered)
	GameEventHandler.tile_hovered.connect(self._is_tile_hovered)
	
	#StartingTiles.generate_starting_tiles()
	#for i in starting_bag.size():
		#current_deck.append(starting_bag[i])
		#available_tiles.append(current_deck[i])
	#
	#var tween = self.create_tween()
	#tween.tween_property(self, "modulate:a", 0, 0.001)
	#tween.tween_property(self, "visible", true, 0.001)
	#tween.tween_property(self, "modulate:a", 1, 0.15)
	#
	#query_combat_rewards(50, 5, 0, 3, 1, [19, 19, 19])

func _bringup_combat_rewards(reward_gold: int, reward_notch_count: int, reward_relics: int, reward_notch_uncommons: int = 0, reward_notch_rares: int = 0, reward_notch_specified: Array = []):
	
	for i in current_deck.size():
		available_tiles.append(current_deck[i])
		
	GeneralManager.rewards_screen_open = true
	GeneralManager.rewards_screen_path = self
	
	var tween = self.create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.001)
	tween.tween_property(self, "visible", true, 0.001)
	tween.tween_property(self, "modulate:a", 1, 0.15)
	
	query_combat_rewards(reward_gold, reward_notch_count, reward_relics, reward_notch_uncommons, reward_notch_rares, reward_notch_specified)

func _ready_rewards(reward_gold: int, reward_notch_count: int, reward_relics: int, reward_notch_uncommons: int = 0, reward_notch_rares: int = 0, reward_notch_specified: Array = []):
	
	for i in current_deck.size():
		available_tiles.append(current_deck[i])
	
	query_combat_rewards(reward_gold, reward_notch_count, reward_relics, reward_notch_uncommons, reward_notch_rares, reward_notch_specified)

func _show_rewards(state: bool):
	
	if state:
		GeneralManager.rewards_screen_open = true
		GeneralManager.rewards_screen_path = self
		
		var tween = self.create_tween()
		tween.tween_property(self, "modulate:a", 0, 0.001)
		tween.tween_property(self, "visible", true, 0.001)
		tween.tween_property(self, "modulate:a", 1, 0.15)

	else:
		var tween = self.create_tween()
		tween.tween_property(self, "modulate:a", 0, 0.15)
		tween.tween_property(self, "visible", false, 0.001)
	
		GeneralManager.rewards_screen_open = false
		GeneralManager.rewards_screen_path = null

func _is_notch_hovered(which: NotchObject, is_hovering: bool):
	if is_hovering == true:
		GameEventHandler.notch_tooltip_requested.emit(which)
		GameEventHandler.tile_tooltip_hide_requested.emit(true)
		
	if is_hovering == false:
		GameEventHandler.notch_tooltip_hide_requested.emit(false)

func _is_tile_hovered(which: GridTile, is_hovering: bool):
	if is_hovering == true:
		GameEventHandler.notch_tooltip_hide_requested.emit(true)

func query_combat_rewards(reward_gold: int, reward_notch_count: int, reward_relics: int, reward_notch_uncommons: int = 0, reward_notch_rares: int = 0, reward_notch_specified: Array = []):
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
		
	if (reward_notch_count + reward_notch_uncommons + reward_notch_rares + reward_notch_specified.size()) > 0:
		set_notch_reward_rng(reward_notch_count, reward_notch_uncommons, reward_notch_rares, reward_notch_specified)
		reward_notch_button = Button.new()
		button_container.add_child(reward_notch_button)
		var notch_button_text_string = "Choose " + str(reward_notch_count + reward_notch_uncommons + reward_notch_rares + reward_notch_specified.size()) + " notches"
		reward_notch_button.text = notch_button_text_string
		reward_notch_button.set_button_icon(reward_notch_button_icon)
		reward_notch_button.pressed.connect(self._on_reward_notch_button_pressed)
		
	if reward_relics > 0:
		for i in reward_relics:
			var rewarded_relic = RelicManager.grab_new_relic("Relic")
			relics.append(rewarded_relic)
			var new_reward_relic_button = reward_relic_button.instantiate()
			button_container.add_child(new_reward_relic_button)
			new_reward_relic_button.assoc_relic = rewarded_relic
			new_reward_relic_button.update_button_data()
			new_reward_relic_button.rewards_relic_button_pressed.connect(self._on_reward_relic_button_pressed)
		
func _on_reward_gold_button_pressed():
	if not reward_gold_button == null:
		GameEventHandler.gold_changed.emit(int(reward_gold_button.text))
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

func _on_reward_relic_button_pressed(which: RewardsRelicButton):
	if not which == null:
		which.queue_free()
	
	await get_tree().create_timer(0.05).timeout
	
	if button_container.get_child_count() == 0:
		await get_tree().create_timer(0.05).timeout
		%RewardsSkipButtonLabel.text = str("PROCEED")

# INFO: It is safe to call this multiple times, as this only populates the UI that appears when you click the notch reward button.
@warning_ignore("shadowed_variable")
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
			#new_notch.update_tile_tooltip.connect(%TileTooltip._show_tooltip)
			var notch_tween = new_notch.create_tween()
			notch_tween.tween_property(new_notch, "modulate:a", 0, 0.001)
			notch_tween.tween_property(new_notch, "modulate:a", 1, 0.15)
			if i == 0:
				new_home_pose = Vector2(various_rng.randi_range(192, 212), various_rng.randi_range(144, 168))
				previous_starting_pose = new_home_pose
			
			else:
				new_home_pose = Vector2(various_rng.randi_range(previous_starting_pose.x + (pose_spacing),  previous_starting_pose.x + (1.95 * pose_spacing)), various_rng.randi_range(144, 168))
				previous_starting_pose = new_home_pose
				
			@warning_ignore("narrowing_conversion")
			var starting_rot = various_rng.randi_range(-22.5, 22.5)
			new_notch.position = new_home_pose
			new_notch.home_pose = new_home_pose
			new_notch.rotation_degrees = starting_rot
			
		for i in draws.size():
			var draws_offset = 64 + 40 * (7 - draws.size())
			var new_tile = GRID_TILE_SCENE.instantiate()
			new_tile.tile = draws[i]
			%PlayerTilesParent.add_child(new_tile)
			new_tile.toggle_monitorable()
			new_tile.position = Vector2(592, 16)
			new_tile.tile.target = Vector2(draws_offset +(80*i), (232 + (((i+1) % 2) * 48)))
			new_tile.spawned_from_bag()
			new_tile.move_to_position(0.5)
			GameEventHandler.play_tile_sound.emit(new_tile)
			await get_tree().create_timer(0.1).timeout

		for i in tiles.size():
			var new_tile = GRID_TILE_SCENE.instantiate()
			new_tile.tile = tiles[i]
			%NewTilesParent.add_child(new_tile)
			new_tile.position = Vector2(208 + (48 * i), 416)
			new_tile.spawned_from_bag()

# WARNING: ONLY CALL THIS ONCE PER COMBAT REWARD. DO NOT CALL THIS MULTIPLE TIMES OTHERWISE IT WILL REPLACE THE LOOT.
func set_notch_reward_rng(notch_count: int, uncommon_count: int = 0, rare_count: int = 0, specified_rewards: Array = []):
	var letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
	var _notch_sum = notch_count + uncommon_count + rare_count + specified_rewards.size()
	
	var whiff = [0]
	
	var standalone_notch_tables = [common_notch_ids, uncommon_notch_ids, rare_notch_ids]
	
	var embedded_notch_tables = [whiff, common_notch_ids, uncommon_notch_ids, rare_notch_ids_no_lexical]
	
	# 65% for a common, 25% for an uncommon, 10% for a rare.
	var standalone_table_weights = PackedFloat32Array([65, 25, 10])
	
	# 25% for a whiff, 35% for a common, 25% for an uncommon, 15% for a rare.
	var embedded_table_weights = PackedFloat32Array([25, 35, 25, 15])
	
	var lexical_tables = [tier_1_lexical_pool, tier_2_lexical_pool, tier_3_lexical_pool, tier_4_lexical_pool, rare_consonant_pool]
	var lexical_table_weights = PackedFloat32Array([35, 25, 20, 15, 5])
	
	for i in notch_count:
		
		
		var notch_table_roll = standalone_notch_tables[reward_rng.rand_weighted(standalone_table_weights)]
		print(notch_table_roll)
		# REMEMBER NITWIT, YOU GOTTA SUBTRACT ONE BECAUSE IT'S AN ARRAY AND IT STARTS AT ZERO.
		var notch_type_roll = notch_table_roll[reward_rng.randi() % notch_table_roll.size()]
		var notch_letter_roll = ""
		if notch_type_roll == 19:
			var lexical_table_roll = lexical_tables[reward_rng.rand_weighted(lexical_table_weights)]
			notch_letter_roll = lexical_table_roll[reward_rng.randi() % lexical_table_roll.size()]
			notch_letter_roll = letters[notch_letter_roll]
			
		var new_notch = Notch.new().new_notch(notch_type_roll, notch_letter_roll)
		notches.append(new_notch)
	
	for i in uncommon_count:
		var notch_type_roll = uncommon_notch_ids[reward_rng.randi() % uncommon_notch_ids.size()]
		var notch_letter_roll = ""
		
		# This should never be needed, but I'm putting it here just to be safe
		#if notch_type_roll == 19:
			#var lexical_table_roll = lexical_tables[reward_rng.rand_weighted(lexical_table_weights)]
			#notch_letter_roll = lexical_table_roll[reward_rng.randi() % lexical_table_roll.size()]
			#notch_letter_roll = letters[notch_letter_roll]
	
		var new_notch = Notch.new().new_notch(notch_type_roll, notch_letter_roll)
		notches.append(new_notch)
		
	for i in rare_count:
		var notch_type_roll = rare_notch_ids[reward_rng.randi() % rare_notch_ids.size()]
		var notch_letter_roll = ""
		
		if notch_type_roll == 19:
			var lexical_table_roll = lexical_tables[reward_rng.rand_weighted(lexical_table_weights)]
			notch_letter_roll = lexical_table_roll[reward_rng.randi() % lexical_table_roll.size()]
			notch_letter_roll = letters[notch_letter_roll]
		
		var new_notch = Notch.new().new_notch(notch_type_roll, notch_letter_roll)
		notches.append(new_notch)
	
	for i in specified_rewards.size():
		var notch_letter_roll = ""
		
		if specified_rewards[i] == 19:
			var lexical_table_roll = lexical_tables[reward_rng.rand_weighted(lexical_table_weights)]
			notch_letter_roll = lexical_table_roll[reward_rng.randi() % lexical_table_roll.size()]
			notch_letter_roll = letters[notch_letter_roll]
		
		var new_notch = Notch.new().new_notch(specified_rewards[i], notch_letter_roll)
		notches.append(new_notch)
	
	# Twice the number of notches - 1 is the option number, lower limit of 3, upper limit of 7.
	var draw_limit = ((notch_count * 2) - 1)
	
	if draw_limit < 3:
			draw_limit = 3
	
	if draw_limit > 7:
			draw_limit = 7
	
	for i in draw_limit:
		draws.append(available_tiles.pop_at(tile_rng.randi() % available_tiles.size()))
		print(draws)

	for i in 5:
		var new_tile: LetterTile
		var type = 0
		var letter: int = 0
		
		if i < 2:
			letter = reward_rng.randi() % 25
			
		if i == 2:
			letter = consonant_letter_pool[reward_rng.randi() % consonant_letter_pool.size()]
		
		if i == 3:
			letter = vowel_letter_pool[reward_rng.randi() % vowel_letter_pool.size()]
			
		if i == 4:
			letter = rare_consonant_pool[reward_rng.randi() % rare_consonant_pool.size()]
		
		var notch_table_roll = embedded_notch_tables[reward_rng.rand_weighted(embedded_table_weights)]
		print(str(notch_table_roll))
		
		if notch_table_roll == whiff:
			new_tile = LetterTile.new().generate_tile(type, letter, 0, 0, 0)
			
		else:
			# REMEMBER NITWIT, YOU GOTTA SUBTRACT ONE BECAUSE IT'S AN ARRAY AND IT STARTS AT ZERO.
			var notch_type_roll = notch_table_roll[reward_rng.randi() % notch_table_roll.size()]
			new_tile = LetterTile.new().generate_tile(type, letter, (notch_type_roll+1), 0, 0)
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
				%PlayerTilesParent.get_child(-1).tile.target = Vector2(592, 16)
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
				is_selected_tile[i].tile.tile_index = current_deck.size()
				current_deck.append(is_selected_tile[i].tile)
				is_selected_tile[i].tile.target = Vector2(592, 16)
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
		
		%ConfirmButton.set_disabled(false)
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
	
	GeneralManager.rewards_screen_open = false
	GeneralManager.rewards_screen_path = null
	
	GameEventHandler.reward_depleted.emit()
	
	if GeneralManager.current_location == "COMBAT":
		GameEventHandler.combat_exited.emit()
