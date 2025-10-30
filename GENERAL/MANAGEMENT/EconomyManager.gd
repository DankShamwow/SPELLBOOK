extends Node

var economy_rng = RandomnessManager.economy_rng

var common_notch_ids = [4, 8, 10, 12, 15, 16, 17, 19]

var uncommon_notch_ids = [1, 2, 3, 5, 6, 9, 13]

var rare_notch_ids = [7, 11, 14, 18, 20]

var common_notch_pack_ids: Array 	= [0, 6, 10, 12, 14, 17, 18, 19, 21]
var uncommon_notch_pack_ids: Array 	= [1, 3, 4, 5, 7, 8, 11, 15]
var rare_notch_pack_ids: Array		= [2, 9, 13, 16, 20, 22]

func determine_purchase_price(which: Object):
	
	var price: int = 0
	
	if which is GridTile:
		var tile_data = which.tile
		
		# Average price for a tile is 50.
		price += economy_rng.randi_range(43, 57)

		# Common notches add an average of 10 gold to the price.
		if common_notch_ids.has(tile_data.notch1):
			price += economy_rng.randi_range(7, 13)
			
		if common_notch_ids.has(tile_data.notch2):
			price += economy_rng.randi_range(7, 13)
		
		if common_notch_ids.has(tile_data.notch3):
			price += economy_rng.randi_range(7, 13)
			
		# Unommon notches add an average of 20 gold to the price.
		if uncommon_notch_ids.has(tile_data.notch1):
			price += economy_rng.randi_range(16, 24)
			
		if uncommon_notch_ids.has(tile_data.notch2):
			price += economy_rng.randi_range(16, 24)
		
		if uncommon_notch_ids.has(tile_data.notch3):
			price += economy_rng.randi_range(16, 24)

		# Rare notches add an average of 40 gold to the price.
		if rare_notch_ids.has(tile_data.notch1):
			price += economy_rng.randi_range(35, 45)
			
		if rare_notch_ids.has(tile_data.notch2):
			price += economy_rng.randi_range(35, 45)
		
		if rare_notch_ids.has(tile_data.notch3):
			price += economy_rng.randi_range(35, 45)

		# If the notch is Gilded, add another 30 gold on average.
		if tile_data.notch1 == LetterTile.NotchTypes.GILDED:
			price += economy_rng.randi_range(25, 35)
		if tile_data.notch2 == LetterTile.NotchTypes.GILDED:
			price += economy_rng.randi_range(25, 35)
		if tile_data.notch3 == LetterTile.NotchTypes.GILDED:
			price += economy_rng.randi_range(25, 35)
	
	if which is Relic:
		if which.relic_rarity == Relic.RelicRarity.COMMON or which.relic_rarity == Relic.RelicRarity.COMMON_BOOK \
		or which.relic_rarity == Relic.RelicRarity.SHOP or which.relic_rarity == Relic.RelicRarity.SHOP_BOOK:
			price += economy_rng.randi_range(135, 165)
			
		elif which.relic_rarity == Relic.RelicRarity.UNCOMMON or which.relic_rarity == Relic.RelicRarity.UNCOMMON_BOOK:
			price += economy_rng.randi_range(200, 250)
			
		elif which.relic_rarity == Relic.RelicRarity.RARE or which.relic_rarity == Relic.RelicRarity.RARE_BOOK:
			price += economy_rng.randi_range(265, 335)
			
		elif which.relic_rarity == Relic.RelicRarity.CURSE or which.relic_rarity == Relic.RelicRarity.CURSE_BOOK:
			price += economy_rng.randi_range(185, 215)
		
	#if which is BlankTile:
	
	if which is NotchPack:
		if common_notch_pack_ids.has(which.pack_type):
			if which.pack_type == 0:
				# Average price of 40
				price += 10 + economy_rng.randi_range(21, 39)
				
			else:
				# Average price of 55
				price += 15 + economy_rng.randi_range(28, 52)
			
		elif uncommon_notch_pack_ids.has(which.pack_type):
			if which.pack_type == 1:
				# Average price of 80
				price += 20 + economy_rng.randi_range(48, 72)
				
			else:
				# Average price of 110
				price += 30 + economy_rng.randi_range(64, 96)
			
		elif rare_notch_pack_ids.has(which.pack_type):
			if which.pack_type == 2:
				# Average price of 160
				price += 40 + economy_rng.randi_range(105, 135)
				
			else:
				# Average price of 220
				price += 60 + economy_rng.randi_range(140, 180)

		if which.pack_type == 8:
			# If it's a Gilded pack, add an average of 50 gold to the price.
			price += economy_rng.randi_range(40, 60)

	return price
