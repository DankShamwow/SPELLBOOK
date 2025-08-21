extends GameEntity

## The Enemy class exists to put data about the enemy into variables that can be accessed automatically.
## Each Enemy has a deck and a list of attacks that pull from that deck.
## When Enemies are properly built using the AttackMaker, their deck, attack list, and attacks should
## be able to be accessed here without any issues.
## Enemy-level functions should be kept here, and data pertaining to a specific enemy should be kept
## inside of that particular enemy's scene and script.
class_name Enemy

var enemy_deck: Array
var enemy_attack_count: int

var enemy_attack_list := []
var enemy_attack_targets := []
var enemy_status_package_list := []
var current_enemy_deck := []

signal perform_attack(attack_to_perform: Array, attack_letter_tiles: Array, debuff_package: Array, pivot_position: Vector2, attacker: Enemy)
signal pass_turn()

func _ready():
	enemy_deck = %EnemyAttackData.EnemyDeck
	enemy_attack_count = %EnemyAttackData.EnemyAttackCount
	enemy_attack_targets = %EnemyAttackData.EnemyAttackTargets
	enemy_status_package_list = %EnemyAttackData.EnemyStatusPackageList
	
	for i in enemy_deck.size():
		current_enemy_deck.append(enemy_deck[i])
	
	for i in enemy_attack_count:
		enemy_attack_list.append(%EnemyAttackData.EnemyAttackList[i])
	
	print(enemy_attack_count)
	print(enemy_attack_list)
	super()

func perform_enemy_attack(attack_number):
	remove_energy(1)
	var attack_letter_tiles = []
	var attack_to_perform = enemy_attack_list[attack_number]
	var debuff_package = enemy_status_package_list[attack_number]
	var target = enemy_attack_targets[attack_number]
	
	for i in attack_to_perform.size():
		attack_letter_tiles.append(current_enemy_deck[attack_to_perform[i]])
		
	perform_attack.emit(attack_to_perform, attack_letter_tiles, debuff_package, (self.position + self.pivot_offset), target, self)
