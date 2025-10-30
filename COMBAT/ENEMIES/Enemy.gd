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

## Master list of enemy words
var enemy_attack_list := []
## The target for each word
var enemy_attack_targets := []
## The intent type for each word
var enemy_attack_intents := []
## The status data for each word
var enemy_status_package_list := []
## Master list of enemy tiles
var current_enemy_deck: Array[LetterTile] = []
## The schedule of words to be played by the enemy next turn. This is an array of integers.
var next_turn_attacks: Array[int] = []
## The number of turns an Enemy has been alive for after a specific activation condition is met.
var active_turns: int = 0
## The dedicated RNG strand for enemies.
var enemy_rng = RandomnessManager.enemy_rng

const INTENT_ICON_SCENE: PackedScene = preload("res://COMBAT/GAME_ENTITY/IntentIcon.tscn")

func _ready():
	
	GameEventHandler.enemy_attack_finished.connect(check_for_ownership)
	
	enemy_deck = %EnemyAttackData.EnemyDeck
	enemy_attack_count = %EnemyAttackData.EnemyAttackCount
	enemy_attack_targets = %EnemyAttackData.EnemyAttackTargets
	enemy_attack_intents = %EnemyAttackData.EnemyAttackIntents
	enemy_status_package_list = %EnemyAttackData.EnemyStatusPackageList
	
	for i in enemy_deck.size():
		current_enemy_deck.append(enemy_deck[i])
	
	for i in enemy_attack_count:
		enemy_attack_list.append(%EnemyAttackData.EnemyAttackList[i])
	super()

func _on_turn_start():
	for i in current_enemy_deck.size():
		current_enemy_deck[i].current_age += 1

## plan_next_turn is a function that schedules the attacks that an enemy will use on their next turn.
## This function should be where the bulk of an enemy's logic is.
## The default logic is to queue all of an enemy's attacks, and then play them in sequence.
func plan_next_turn():
	next_turn_attacks = []
	
	for i in %IntentBox.get_child_count():
		%IntentBox.get_child(i).queue_free()
	
	for i in enemy_attack_list.size():
		schedule_attack(i)

## schedule_attack is called to schedule an enemy attack based on its number in the enemy's attack list.
## Scheduling attack means that it will be played next turn if the enemy has the energy to do so.
func schedule_attack(attack_number: int):
	# We're queueing the NUMBER of the attack with this, not the full array for the attack.
	# The data is elsewhere, so we only want to append a number to this array.
	next_turn_attacks.append(attack_number)
	var attack_intent = INTENT_ICON_SCENE.instantiate()
	%IntentBox.add_child(attack_intent)
	attack_intent.type = IntentIcon.IntentType[enemy_attack_intents[attack_number]]
	attack_intent.update_intent_info()
	attack_intent.is_intent = true					## TODO: Rename this to "is_hoverable"
	attack_intent.related_enemy = self
	attack_intent.related_attack = attack_number
	attack_intent.intent_hovered.connect(self.get_parent().get_parent().find_child("IntentTooltip")._on_intent_hovered) ## TODO: Put this on the events bus

func check_for_ownership(which: Enemy):
	if which == self:
		_perform_next_attack()
		
func _perform_next_attack():
	pass

## perform_enemy_attack performs the scheduled attack at the index given. Zero indexed.
func perform_enemy_attack(attack_number):
	if self.health <= 0:
		return
	
	remove_energy(1)
	
	var attack_letter_tiles = []
	
	var attack_to_perform = enemy_attack_list[next_turn_attacks[attack_number]]
	var debuff_package = enemy_status_package_list[next_turn_attacks[attack_number]]
	var target = enemy_attack_targets[next_turn_attacks[attack_number]]
	
	for i in attack_to_perform.size():
		attack_letter_tiles.append(current_enemy_deck[attack_to_perform[i]])
		
	GameEventHandler.perform_attack.emit(attack_to_perform, attack_letter_tiles, debuff_package, (self.position + self.pivot_offset), target, self)

	await %IntentBox.get_child(0).juice_attack_perform()
	%IntentBox.get_child(0).queue_free()

func on_turn_end(_count):
	plan_next_turn()
	super(_count)
