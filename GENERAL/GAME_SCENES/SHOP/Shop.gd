extends Control
## Shops are where the player can buy new Tiles, Relics, and buy Notch Packs to hopefully get more useful Notches.
class_name Shop

var shop_rng						= RandomnessManager.shop_rng

var first_click: bool = true

var common_notch_ids 				= GeneralManager.common_notch_ids
var uncommon_notch_ids 				= GeneralManager.uncommon_notch_ids
var rare_notch_ids 					= GeneralManager.rare_notch_ids
var rare_notch_ids_no_lexical 		= GeneralManager.rare_notch_ids_no_lexical
var consonant_letter_pool 			= GeneralManager.consonant_letter_ids
var vowel_letter_pool 				= GeneralManager.vowel_letter_ids
var rare_consonant_pool 			= GeneralManager.rare_consonant_pool

var common_notch_pack_ids: Array 	= [0, 6, 10, 12, 14, 17, 18, 19, 21]
var uncommon_notch_pack_ids: Array 	= [1, 3, 4, 5, 7, 8, 11, 15]
var rare_notch_pack_ids: Array		= [2, 9, 13, 16, 20, 22]

var whiff = []
var embedded_notch_tables = [whiff, common_notch_ids, uncommon_notch_ids, rare_notch_ids_no_lexical]
var embedded_table_weights = PackedFloat32Array([25, 35, 25, 15])

var consonant_tile_stock_count 		= GeneralManager.consonant_tile_stock
var vowel_tile_stock_count 			= GeneralManager.vowel_tile_stock
var unwieldy_tile_stock_count 		= GeneralManager.unwieldy_tile_stock
var blank_tile_stock_count 			= GeneralManager.blank_tile_stock
var any_notch_pack_stock_count 		= GeneralManager.any_notch_pack_stock
var uncommon_notch_pack_stock_count = GeneralManager.uncommon_notch_pack_stock
var non_shop_relic_stock_count 		= GeneralManager.non_shop_relic_stock
var book_relic_stock_count 			= GeneralManager.book_relic_stock
var shop_relic_stock_count 			= GeneralManager.shop_relic_stock

var tile_stock: Array 				= []
var blank_tile_stock: Array 		= []
var notch_pack_stock: Array 		= []
var relic_stock: Array 				= []
var book_relic_stock: Array 		= []

const GRID_TILE_SCENE: PackedScene = preload("res://TILE/GRID_TILE/GridTile.tscn")
const NOTCH_PACK_SCENE: PackedScene = preload("res://GENERAL/GAME_SCENES/SHOP/NotchPack.tscn")
const FOLLOWER_TEXTBOX_SCENE: PackedScene = preload("res://GENERAL/OTHER/FollowerTextbox.tscn")

func _ready() -> void:
	#region Signal Setup
	GameEventHandler.notch_pack_clicked.connect(_on_shop_object_clicked)
	GameEventHandler.relic_clicked.connect(_on_shop_object_clicked)
	GameEventHandler.tile_clicked.connect(_on_shop_object_clicked)
	#endregion

	#region Tile Generation
	for i in consonant_tile_stock_count:
		_generate_new_shop_tile("CONSONANT")
	for i in vowel_tile_stock_count:
		_generate_new_shop_tile("VOWEL")
	for i in unwieldy_tile_stock_count:
		_generate_new_shop_tile("UNWIELDY")
	#endregion

	#region Relic Generation
	for i in non_shop_relic_stock_count:
		var stocked_relic = RelicManager.grab_new_relic("Relic")
		stocked_relic.purchase_price = EconomyManager.determine_purchase_price(stocked_relic)
		relic_stock.append(stocked_relic)
		if stocked_relic.relic_type == Relic.RelicType.BOOK:
			book_relic_stock.append(stocked_relic)
			
	for i in book_relic_stock_count:
		var stocked_relic = RelicManager.grab_new_relic("Book")
		stocked_relic.purchase_price = EconomyManager.determine_purchase_price(stocked_relic)
		relic_stock.append(stocked_relic)
		book_relic_stock.append(stocked_relic)
	
	#for i in shop_relic_stock_count:
		#RelicManager.grab_new_relic("Shop")
		
	#endregion

	#region Notch Pack Generation
	for i in any_notch_pack_stock_count:
		_generate_new_notch_pack("ANY")
	for i in uncommon_notch_pack_stock_count:
		_generate_new_notch_pack("UNCOMMON")
	
	#endregion

	#region Blank Tile Generation
	for i in blank_tile_stock_count:
		_generate_new_shop_tile("CONSONANT", true)
	#endregion

#region Generating Objects
func _generate_new_shop_tile(letter_type: String, is_blank: bool = false):
	var new_tile: LetterTile
	var type = 0
	var letter: int = 0

	if letter_type == "CONSONANT":
		letter = consonant_letter_pool[shop_rng.randi() % consonant_letter_pool.size()]
		
	if letter_type == "VOWEL":
		letter = vowel_letter_pool[shop_rng.randi() % vowel_letter_pool.size()]
			
	if letter_type == "UNWIELDY":
		letter = rare_consonant_pool[shop_rng.randi() % rare_consonant_pool.size()]
		
	if is_blank:
		letter = 0
		
	var notch_table_roll = embedded_notch_tables[shop_rng.rand_weighted(embedded_table_weights)]
		
	if notch_table_roll == whiff:
		new_tile = LetterTile.new().generate_tile(type, letter, 0, 0, 0, is_blank)
			
	else:
		# REMEMBER NITWIT, YOU GOTTA SUBTRACT ONE BECAUSE IT'S AN ARRAY AND IT STARTS AT ZERO.
		var notch_type_roll = notch_table_roll[shop_rng.randi() % notch_table_roll.size()]
		new_tile = LetterTile.new().generate_tile(type, letter, (notch_type_roll+1), 0, 0, is_blank)
	
	var grid_tile = GRID_TILE_SCENE.instantiate()
	grid_tile.tile = new_tile
	
	grid_tile.purchase_price = EconomyManager.determine_purchase_price(grid_tile)
	
	if is_blank:
		blank_tile_stock.append(grid_tile)
		grid_tile.tile.tile_index = -1
		
	else:
		tile_stock.append(grid_tile)

func _generate_new_notch_pack(pack_type: String, pack_size: int = 0):
	var standard_table_weights 	= PackedFloat32Array([65, 25, 10])
	var uncommon_table_weights	= PackedFloat32Array([85, 15])
	
	var common_pack_weights 	= PackedFloat32Array([75, 3.125, 3.125, 3.125, 3.125, 3.125, 3.125, 3.125, 3.125])
	var uncommon_pack_weights	= PackedFloat32Array([72, 4, 4, 4, 4, 4, 4, 4])
	var rare_pack_weights		= PackedFloat32Array([70, 6, 6, 6, 6, 6])
	
	var new_pack: NotchPack
	
	var table_roll = common_notch_pack_ids
	var type_roll: int = 0
	var size_roll: int = 3
	
	if pack_type == "ANY":
		var tables = [common_notch_pack_ids, uncommon_notch_pack_ids, rare_notch_pack_ids]
		table_roll = tables[shop_rng.rand_weighted(standard_table_weights)]
	
	if pack_type == "UNCOMMON":
		var tables = [uncommon_notch_pack_ids, rare_notch_pack_ids]
		table_roll = tables[shop_rng.rand_weighted(uncommon_table_weights)]
	
	if table_roll == common_notch_pack_ids:
		type_roll = table_roll[shop_rng.rand_weighted(common_pack_weights)]
	
	elif table_roll == uncommon_notch_pack_ids:
		type_roll = table_roll[shop_rng.rand_weighted(uncommon_pack_weights)]
	
	elif table_roll == rare_notch_pack_ids:
		type_roll = table_roll[shop_rng.rand_weighted(rare_pack_weights)]
	
	else:
		type_roll = 0
	
	if pack_size == 0:
		size_roll = shop_rng.randi_range(3, 4)

	new_pack = NOTCH_PACK_SCENE.instantiate()
	@warning_ignore("int_as_enum_without_cast")
	new_pack.pack_type = type_roll
	new_pack.pack_size = size_roll
	new_pack.purchase_price = EconomyManager.determine_purchase_price(new_pack)
	
	for i in new_pack.pack_size:
		
		# Truly random packs
		if new_pack.pack_type == 0:
			new_pack.pack_contents.append(common_notch_ids[shop_rng.randi() % common_notch_ids.size()])
		elif new_pack.pack_type == 1:
			new_pack.pack_contents.append(uncommon_notch_ids[shop_rng.randi() % uncommon_notch_ids.size()])
		elif new_pack.pack_type == 2:
			new_pack.pack_contents.append(rare_notch_ids[shop_rng.randi() % rare_notch_ids.size()])
		
		# Packs of all one type.
		else:
			new_pack.pack_contents.append((new_pack.pack_type - 3))
	
	notch_pack_stock.append(new_pack)
#endregion

#region Management
func _manage_covering(state: bool = false) -> void:
	var tween = %ScreenCovering.create_tween()
	
	if not state:
		tween.tween_property(%ScreenCovering, "modulate:a", (0.65 * int(state)), 0.15)
		tween.tween_property(%ScreenCovering, "visible", state, 0.001)
		%ScreenCovering.mouse_filter = MOUSE_FILTER_IGNORE
	
	if state:
		%ScreenCovering.mouse_filter = MOUSE_FILTER_STOP
		tween.tween_property(%ScreenCovering, "visible", state, 0.001)
		tween.tween_property(%ScreenCovering, "modulate:a", (0.65 * int(state)), 0.15)

func _on_shop_button_pressed() -> void:
	_manage_covering(true)
	
	var tile_squish_factor = float(10.0 / (tile_stock.size() + 1))
	var relic_squish_factor = float(6.0 / (relic_stock.size() + 1))
	var pack_squish_factor = float(6.0 / (notch_pack_stock.size() + 1))
	var blank_squish_factor = float(3.0 / (blank_tile_stock.size() + 1))
	
	var tween = %ShopScreenParent.create_tween()
	
	tween.tween_property(%ShopScreenParent, "visible", true, 0.001)
	tween.tween_property(%ShopScreenParent, "modulate:a", 1, 0.15)
	
	if first_click:
		first_click = false
	
		#region Tile Stock Management
		for i in tile_stock.size():
			var stocked_tile = tile_stock[i]
			var follower_text = FOLLOWER_TEXTBOX_SCENE.instantiate()
			follower_text.paired_node = stocked_tile
			follower_text._set_follower_text(str(follower_text.paired_node.purchase_price))
			
			%ShopTiles.add_child(stocked_tile)
			%FollowerTextParent.add_child(follower_text)
			
			if tile_stock.size() <= 9:
				stocked_tile.position = Vector2((304 - (32 * (tile_stock.size() - 1)) + (64 * i)), 168)
				
			else:
				stocked_tile.position = Vector2((304 - (28 * tile_squish_factor * (tile_stock.size() - 1)) + (56 * tile_squish_factor * i)), 168)
		#endregion
		
		#region Relic Stock Management
		for i in relic_stock.size():
			var stocked_relic = relic_stock[i]
			var follower_text = FOLLOWER_TEXTBOX_SCENE.instantiate()
			follower_text.paired_node = stocked_relic
			follower_text._set_follower_text(str(follower_text.paired_node.purchase_price))
			%ShopRelics.add_child(stocked_relic)
			%FollowerTextParent.add_child(follower_text)
			
			if relic_stock.size() <= 5:
				stocked_relic.position = Vector2((304 - (32 * (relic_stock.size() - 1)) + (64 * i)), 264)
				
			else:
				stocked_relic.position = Vector2((304 - (28 * relic_squish_factor * (relic_stock.size() - 1)) + (56 * relic_squish_factor * i)), 264)
		#endregion
		
		#region Notch Pack Management
		for i in notch_pack_stock.size():
			var stocked_pack = notch_pack_stock[i]
			var follower_text = FOLLOWER_TEXTBOX_SCENE.instantiate()
			follower_text.paired_node = stocked_pack
			follower_text._set_follower_text(str(follower_text.paired_node.purchase_price))
			%ShopPacks.add_child(stocked_pack)
			%FollowerTextParent.add_child(follower_text)
			
			if notch_pack_stock.size() <= 5:
				stocked_pack.position = Vector2((304 - (32 * (notch_pack_stock.size() - 1)) + (64 * i)), 360)
				
			else:
				stocked_pack.position = Vector2((304 - (28 * pack_squish_factor * (notch_pack_stock.size() - 1)) + (56 * pack_squish_factor * i)), 360)
		#endregion

		#region Blank Tile Management
		for i in blank_tile_stock.size():
			var stocked_blank = blank_tile_stock[i]
			var follower_text = FOLLOWER_TEXTBOX_SCENE.instantiate()
			follower_text.paired_node = stocked_blank
			follower_text._set_follower_text(str(follower_text.paired_node.purchase_price))
			%ShopBlanks.add_child(stocked_blank)
			%FollowerTextParent.add_child(follower_text)
			
			if blank_tile_stock.size() <= 3:
				stocked_blank.position = Vector2(72, (304 - (32 * (blank_tile_stock.size() - 1)) + (72 * i)))
				
			else:
				stocked_blank.position = Vector2(72, (304 - (24 * blank_squish_factor * (blank_tile_stock.size() - 1)) + (64 * blank_squish_factor * i)))

func _on_shop_back_button_pressed() -> void:
	var tween = %ShopScreenParent.create_tween()
	
	tween.tween_property(%ShopScreenParent, "modulate:a", 0, 0.15)
	tween.tween_property(%ShopScreenParent, "visible", false, 0.001)
	
	_manage_covering()

func _on_shop_object_clicked(which: Object, _action: int) -> void:
	# If they can't buy it, grumble and don't bother finishing up.
	if which.purchase_price > GeneralManager.gold:
		print("Not enough gold!")
		print(str(GeneralManager.gold))
		if which is GridTile:
			which.grumble_tile()
		elif which is Relic:
			which.grumble_relic()
		else:
			which.grumble_object()
			
		return
	
	else:
		print("Buying!")
		# Take the player's money from them, then proceed onto the next steps:
		GameEventHandler.gold_changed.emit((-1 * which.purchase_price))
		
		for i in %FollowerTextParent.get_child_count():
			if %FollowerTextParent.get_child(i).paired_node == which and not %FollowerTextParent.get_child(i) == null:
				%FollowerTextParent.get_child(i).queue_free()
		
		if which.get_parent() == %ShopTiles:
			which = which as GridTile
			which.reparent(%ShopKillParent)
			which.tile.tile_index = GeneralManager.current_deck.size()
			GeneralManager.current_deck.append(which.tile)
			which.tile.target = Vector2(592.0, 16.0)
			which.is_being_added_to_deck()
			which.move_to_position(0.5)
			
		elif which.get_parent() == %ShopBlanks:
			which = which as GridTile
			which.reparent(%ShopKillParent)
			GameEventHandler.tile_modify_popup.emit(which)
			which.is_vanishing()
			
			_cleanup()
			
		elif which.get_parent() == %ShopPacks:
			which = which as NotchPack
			which.reparent(%ShopKillParent)
			GameEventHandler.specialty_rewards_popup.emit(0, 0, 0, which.pack_contents, false, 7, true, true)
			
		elif which.get_parent() == %ShopRelics:
			which = which as Relic
			which.reparent(%ShopKillParent)
			GameEventHandler.add_relic.emit(which.relic_id, false, 0)
			which.visible = false
			
		else:
			print("Invalid Shop Object Clicked!")
			return

		_cleanup()
		

func _cleanup(instant: bool = false):
	if not instant:
		await get_tree().create_timer(0.55).timeout
	
	for i in %ShopKillParent.get_child_count():
		if not %ShopKillParent.get_child(i) == null:
			%ShopKillParent.get_child(i).queue_free()

func _on_leave_button_pressed() -> void:
	for i in book_relic_stock.size():
		RelicManager.return_relic_to_pool(book_relic_stock[i].relic_id)
	GameEventHandler.shop_exited.emit()
#endregion
