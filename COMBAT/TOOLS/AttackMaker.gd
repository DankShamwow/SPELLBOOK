extends Control

@export var grid_tile_scene: PackedScene = preload("res://TILE/GRID_TILE/GridTile.tscn")
@export var status_effect_scene: PackedScene = preload("res://COMBAT/STATUSES/StatusEffect.tscn")
@export var status_dictionary = StatusDictionary.StatusEffectList
@export var word_origin: Node2D
@export var attack_list: VBoxContainer

var deck_size := 0
var attack_count := 0

var attack_tiles = []
var attack_targets = []
var attack_intents = []
var attacks = []
var status_packages = []

func _on_attack_word_submitted(new_text: String):
	var input_array = new_text.split(", ", true, 3)
	var new_attack = []
	for i in len(input_array[0]):
		var letter = LetterTile.TileLetter[new_text[i].to_upper()]
		var new_LetterTile = LetterTile.new().new_tile(LetterTile.TileType.BASIC, letter, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, deck_size)
		deck_size += 1
		var attack_tile = grid_tile_scene.instantiate()
		attack_tile.scale = Vector2(0.5, 0.5)
		attack_tile.position = Vector2(56.0 + (40 * i), (120 + (36 * attack_count)))
		attack_tile.tile = new_LetterTile
		attack_tile.toggle_monitorable()
		new_attack.append(attack_tile)
		%TilesParent.add_child(attack_tile)
	
	attack_count += 1
	attack_targets.append(str(input_array[1]))
	attack_intents.append(str(input_array[2]))
	
	print(new_attack)
	
	attacks.append(new_attack)
	
	%LineEdit.clear()
	
func _on_attack_debuff_submitted(new_text: String):
	
	var input_array = new_text.split(", ", true, 5)
	var new_attack_status = []
	for i in input_array.size():
		new_attack_status.append(input_array[i])
	
	new_attack_status[1] = new_attack_status[1].to_int()
	new_attack_status[2] = new_attack_status[2].to_int()
	new_attack_status[3] = new_attack_status[3].to_int()
	
	var new_status_icon = status_effect_scene.instantiate()
	var new_status = status_dictionary.get(new_attack_status[0])
	new_status_icon.set_script(new_status)
	%StatusParent.add_child(new_status_icon)
	new_status_icon.amount = new_attack_status[1]
	new_status_icon.does_decay = bool(new_attack_status[2])
	print(bool(new_attack_status[2]))
	new_status_icon.duration = new_attack_status[3]
	new_status_icon._update_graphics()
	
	
	if status_packages.size() < attacks.size():
		var attack_status_package = []
		
		new_status_icon.position = Vector2(384 + (32 * attack_status_package.size()), (120.0 + (32 * status_packages.size())))
		
		attack_status_package.append(new_attack_status)
		
		status_packages.append(attack_status_package)

	elif status_packages.size() == 0:
		var attack_status_package = []
		
		new_status_icon.position = Vector2(384 + (32 * attack_status_package.size()), (120.0 + (32 * status_packages.size())))
		
		attack_status_package.append(new_attack_status)
		
		status_packages.append(attack_status_package)

	else:
		new_status_icon.position = Vector2(384 + (32 * status_packages[-1].size()), (120.0 + (32 * (status_packages.size() - 1))))
		
		status_packages[-1].append(new_attack_status)
	
	%DebuffText.clear()
	print(status_packages)

func _add_blank_debuff_package():
	var new_status_package = []
	
	status_packages.append(new_status_package)


	#var new_attack = HBoxContainer.new()
	#attack_list.add_child(new_attack)
	#for i in len(new_text):
		#var letter = LetterTile.TileLetter[new_text[i].to_upper()]
		#print(letter)
		#var new_LetterTile = LetterTile.new().new_tile(LetterTile.TileType.BASIC, letter, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, attack_tiles.size())		
		#var attack_tile = grid_tile_scene.instantiate()
		#attack_tile.tile = new_LetterTile
		#attack_tile.toggle_monitorable(true)
		#new_attack.add_child(attack_tile)
		#attack_tiles.append(attack_tile)
	#%LineEdit.clear()
	
func _on_export_button_pressed():
	var export = FileAccess.open("res://COMBAT/new_enemy_deck.gd", FileAccess.WRITE)
	export.store_line("extends Node")
	export.store_line("")
	export.store_line("var EnemyAttackCount = " + str(attack_count))
	export.store_line("")
	export.store_line("var EnemyDeck = [")
	
	for i in attacks.size():
		var exported_attack = attacks[i]
		for j in exported_attack.size():
			var type 		= str(exported_attack[j].tile.TileType.keys()[exported_attack[j].tile.type])
			var letter 		= str(exported_attack[j].tile.TileLetter.keys()[exported_attack[j].tile.true_letter])
			var notch1		= str(exported_attack[j].tile.NotchTypes.keys()[exported_attack[j].tile.notch1])
			var notch2		= str(exported_attack[j].tile.NotchTypes.keys()[exported_attack[j].tile.notch2])
			var notch3		= str(exported_attack[j].tile.NotchTypes.keys()[exported_attack[j].tile.notch3])
			var tile_index 	= str(exported_attack[j].tile.tile_index)
			export.store_line("LetterTile.new().new_tile(" + "LetterTile.TileType." + type + ", " + "LetterTile.TileLetter." + letter + ", " + "LetterTile.NotchTypes." + notch1 + ", " + "LetterTile.NotchTypes." + notch2 + ", " + "LetterTile.NotchTypes." + notch3 + ", " + tile_index + ")" + ",")
	export.store_line("]")
	export.store_line("")
	
	for i in attacks.size():
		var exported_attack = attacks[i]
		export.store_string("var EnemyAttack" + str(i) + " = [")
		for j in exported_attack.size():
			var tile_index = str(exported_attack[j].tile.tile_index)
			export.store_string(tile_index + ",")
		export.store_line("]")
		export.store_line("")
	
	if status_packages.size() > 0:
		for i in status_packages.size():
			var exported_status_package = status_packages[i]
			if exported_status_package.size() > 0:
				export.store_string("var EnemyStatusPackage" + str(i) + " = [")
				for j in exported_status_package.size():
					export.store_string(str(str(exported_status_package[j]) + ","))
				export.store_line("]")
				export.store_line("")
			
			else:
				export.store_line("var EnemyStatusPackage" + str(i) + " = []")
				export.store_line("")
	
	export.store_line("var EnemyAttackList = [")
	for i in attacks.size():
		export.store_line(str("EnemyAttack" + str(i) + ","))
	export.store_line("]")
	export.store_line("")
	
	export.store_line("var EnemyAttackTargets = [")
	for i in attacks.size():
		export.store_line(str('"' + attack_targets[i] + '"' + ","))
	export.store_line("]")
	export.store_line("")
		
	export.store_line("var EnemyAttackIntents = [")
	for i in attacks.size():
		export.store_line(str('"' + attack_intents[i] + '"' + ","))
	export.store_line("]")
	export.store_line("")
	
	export.store_line("var EnemyStatusPackageList = [")
	for i in status_packages.size():
		export.store_line(str("EnemyStatusPackage" + str(i) + ","))
	export.store_line("]")
	export.store_line("")
	
	#for i in attack_list.get_child_count():
		#for j in attack_list.get_child(i).get_child_count():
			#var type 		= str(attack_list.get_child(i).get_child(j).tile.TileType.keys()[attack_list.get_child(i).get_child(j).tile.type])
			#var letter 		= str(attack_list.get_child(i).get_child(j).tile.TileLetter.keys()[attack_list.get_child(i).get_child(j).tile.letter])
			#var notch1		= str(attack_list.get_child(i).get_child(j).tile.NotchTypes.keys()[attack_list.get_child(i).get_child(j).tile.notch1])
			#var notch2		= str(attack_list.get_child(i).get_child(j).tile.NotchTypes.keys()[attack_list.get_child(i).get_child(j).tile.notch2])
			#var notch3		= str(attack_list.get_child(i).get_child(j).tile.NotchTypes.keys()[attack_list.get_child(i).get_child(j).tile.notch3])
			#var tile_index 	= str(attack_list.get_child(i).get_child(j).tile.tile_index)
			#export.store_line("LetterTile.new().new_tile(" + "LetterTile.TileType." + type + ", " + "LetterTile.TileLetter." + letter + ", " + "LetterTile.NotchTypes." + notch1 + ", " + "LetterTile.NotchTypes." + notch2 + ", " + "LetterTile.NotchTypes." + notch3 + ", " + tile_index + ")" + ",")
	#export.store_line("]")
	#export.store_line("")
	#
	#for i in attack_list.get_child_count():
		#export.store_line("var EnemyAttack" + str(i) + " = [")
		#for j in attack_list.get_child(i).get_child_count():
			#var tile_index 	= str(attack_list.get_child(i).get_child(j).tile.tile_index)
			#export.store_line(tile_index + ",")
		#export.store_line("]")
		#export.store_line("")
		#
	#export.store_line("var EnemyAttackList = [")
	#for i in attack_list.get_child_count():
		#export.store_line(str("EnemyAttack" + str(i) + ","))
	#export.store_line("]")
