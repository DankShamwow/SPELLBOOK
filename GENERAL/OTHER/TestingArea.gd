extends Control

var grid_tile_scene = preload("res://TILE/GRID_TILE/GridTile.tscn")

func _ready():
	for i in 6:
		
		var type = 0
		var letter = randi() % 26
		var notch1 = 0
		var notch2 = 0
		var notch3 = 0
		
		if i == 0:
			notch1 = randi_range(1, 11)
			notch2 = 0
			notch3 = 0
			
		if i == 1:
			notch1 = randi_range(1, 11)
			notch2 = randi_range(1, 11)
			notch3 = 0
			
		if i == 2:
			notch1 = randi_range(1, 11)
			notch2 = 0
			notch3 = randi_range(1, 11)
		
		var new_tile = LetterTile.new().generate_tile(type, letter, notch1, notch2, notch3)
		var random_tile = grid_tile_scene.instantiate()
		random_tile.tile = new_tile
		if i < 3:
			random_tile.toggle_monitorable(true)
		
		$Node2D.add_child(random_tile)
		random_tile.position = Vector2(randi_range(100, 300), randi_range(100, 300))
		
	print(get_tree().get_nodes_in_group("Notches to Add"))
