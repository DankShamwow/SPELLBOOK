extends Control

@export var grid_tile_scene: PackedScene = preload("res://TILE/GridTile.tscn")
@export var word_origin: Node2D
@export var attack_list: VBoxContainer
@export var attack_letters: PackedScene = preload("res://h_box_container.tscn")

var attack_tiles = []

func _on_attack_word_submitted(new_text: String):
	var new_attack = attack_letters.instantiate()
	attack_list.add_child(new_attack)
	for i in len(new_text):
		var letter = LetterTile.TileLetter[new_text[i].to_upper()]
		print(letter)
		var new_LetterTile = LetterTile.new().new_tile(LetterTile.TileType.BASIC, letter, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.EMPTY, attack_tiles.size())		
		var attack_tile = grid_tile_scene.instantiate()
		attack_tile.scale = Vector2(4, 4)
		attack_tile.tile = new_LetterTile
		new_attack.add_child(attack_tile)
		attack_tiles.append(attack_tile)
	%LineEdit.clear()
	
func _on_export_button_pressed():
	var export = FileAccess.open("new_attack_export.gd", FileAccess.WRITE)
	export.store_line("extends Node")
	export.store_line("")
	for i in attack_list.get_child_count():
		export.store_line("var EnemyAttack" + str(i) + " = [")
		for j in attack_list.get_child(i).get_child_count():
			var type 		= str(attack_list.get_child(i).get_child(j).tile.TileType.keys()[attack_list.get_child(i).get_child(j).tile.type])
			var letter 		= str(attack_list.get_child(i).get_child(j).tile.TileLetter.keys()[attack_list.get_child(i).get_child(j).tile.letter])
			var notch1		= str(attack_list.get_child(i).get_child(j).tile.NotchTypes.keys()[attack_list.get_child(i).get_child(j).tile.notch1])
			var notch2		= str(attack_list.get_child(i).get_child(j).tile.NotchTypes.keys()[attack_list.get_child(i).get_child(j).tile.notch2])
			var notch3		= str(attack_list.get_child(i).get_child(j).tile.NotchTypes.keys()[attack_list.get_child(i).get_child(j).tile.notch3])
			var tile_index 	= str(attack_list.get_child(i).get_child(j).tile.tile_index)
			export.store_line("LetterTile.new().new_tile(" + "LetterTile.TileType." + type + ", " + "LetterTile.TileLetter." + letter + ", " + "LetterTile.NotchTypes." + notch1 + ", " + "LetterTile.NotchTypes." + notch2 + ", " + "LetterTile.NotchTypes." + notch3 + ", " + tile_index + ")" + ",")
		export.store_line("]")
		export.store_line("")
