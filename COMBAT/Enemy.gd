extends GameEntity

## The Enemy class exists to put data about the enemy into variables that can be accessed automatically.
## Each Enemy has a deck and a list of attacks that pull from that deck.
## When Enemies are properly built using the AttackMaker, their deck, attack list, and attacks should
## be able to be accessed here without any issues.
## Enemy-level functions should be kept here, and data pertaining to a specific enemy should be kept
## inside of that particular enemy's scene and script.
class_name Enemy

var play_area_script = "res://GENERAL/PlayArea2.gd"

var grid_tile_scene: PackedScene = preload("res://TILE/GridTile.tscn")

## mult_values determines the multiplier on the score based on the length of a word.
var mult_values		:= GeneralManager.mult_values

var enemy_deck: Array
var enemy_attack_count: int

var enemy_attack_list := []
var current_enemy_deck := []
var tile_array := []
var to_destroy := []
var allow_attack_scoring := false
var allow_tile_deletion := false

signal perform_attack(attack_to_perform: Array, attack_letter_tiles: Array, pivot_position: Vector2)
signal deal_damage_to_player(total_score)
signal pass_turn()

func _ready():
	enemy_deck = %EnemyAttackData.EnemyDeck
	enemy_attack_count = %EnemyAttackData.EnemyAttackCount
	
	for i in enemy_deck.size():
		current_enemy_deck.append(enemy_deck[i])
	
	for i in enemy_attack_count:
		enemy_attack_list.append(%EnemyAttackData.EnemyAttackList[i])
	
	print(enemy_attack_count)
	print(enemy_attack_list)
	super()

func perform_enemy_attack(attack_number, target):
	remove_energy(1)
	var attack_letter_tiles = []
	var attack_to_perform = enemy_attack_list[attack_number]
	for i in attack_to_perform.size():
		attack_letter_tiles.append(current_enemy_deck[attack_to_perform[i]])
		
	perform_attack.emit(attack_to_perform, attack_letter_tiles, self.pivot_offset, target)



#func perform_enemy_attack(attack_number, target):
	#allow_tile_deletion = false
	#var points_score = 0
	#var mult_score = 0
	#var letter_score = 0
	#var total_score = 0
#
	#var attack_to_perform = enemy_attack_list[attack_number]
	#for i in attack_to_perform.size():
		#
		#var generated_tile = grid_tile_scene.instantiate()
		#var current_tile = attack_to_perform[i]
		#
		#generated_tile.tile = current_enemy_deck[current_tile]
		#self.add_child(generated_tile)
		#
		#generated_tile.scale = Vector2(0.5, 0.5)
		#generated_tile.position = Vector2(12, 16)
		#generated_tile.spawned_in()
		#
		#tile_array.append(generated_tile)
		#
		#var first_tile = tile_array.front()
		#var scaling_factor = float(7.0 / (tile_array.size()+1))
		#
		#if tile_array.size() <= 6:
			#scaling_factor = 1
			## We need the first tile to be able to determine the positions of the rest of the tiles.
			#first_tile.tile.target = Vector2(-112 - (9 * tile_array.size() - 9), 0) # Originally 20, change to 16?
			#var first_tile_x = first_tile.tile.target.x
			#for j in tile_array.size():
				#tile_array[j].tile.target = Vector2(first_tile_x + (18 * j), 0) # Originally 40, change to 32?
				#tile_array[j].scale_to_word_size(scaling_factor)
				#
		#elif tile_array.size() > 6:
			#scaling_factor = float(7.0 / (tile_array.size()+1))
			#first_tile = tile_array.front()
			#first_tile.tile.target = Vector2(-112 - (9 * tile_array.size() - 9)*scaling_factor, 0) # Originally 10 and 20, change to 8 and 16?
			#var first_tile_x = first_tile.tile.target.x
			#for j in tile_array.size():
				#tile_array[j].tile.target = Vector2((first_tile_x + (18 * j *scaling_factor)), 0) # Originally 40, change to 32?
				#tile_array[j].scale_to_word_size(scaling_factor)
				#
		#await get_tree().create_timer(0.1).timeout
#
	#while allow_attack_scoring == false:
		#await get_tree().create_timer(0.001).timeout
#
	#for i in tile_array.size():
		#letter_score = tile_array[i].score_tile()
		#points_score += letter_score
		#mult_score = mult_values[i]
		#await get_tree().create_timer(0.1).timeout
	#
	#total_score = points_score * mult_score
	#
	#if target == Character:
		#var damage = total_score
		#deal_damage_to_player.emit(damage)
	#else:
		#gain_block(total_score)
	#
	#await get_tree().create_timer(1).timeout
	#allow_tile_deletion = true
	#
	#for i in attack_to_perform.size():
		#tile_array.back().tile.target = Vector2(12, 16)
		#tile_array.back().is_dying()
		#var tile_just_scored = tile_array.pop_back()
		#to_destroy.append(tile_just_scored)
	#
	#allow_attack_scoring = false
	#return true
