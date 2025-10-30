extends Control
class_name GameEntity

@export_group("Text")
@export var entity_name: String
@export_multiline var entity_description: String

var current_target = GeneralManager.current_target
var various_rng = RandomnessManager.various_rng

#region GameEntity Stats
## The maximum health of the game entity
var max_health: 					int

## The current health of the game entity
var health: 						int

## The current block value of the game entity. Damage taken needs to deplete this before
## damage to the entity's current health can be taken.
var block: 							int = 0

## This is the flat point bonus that entities can have.
var point_bonus: 					int = 0

## This is the flat word length bonus that entities can have.
var length_bonus: 					int = 0

## This is the flat attack point bonus that entities can have.
var attack_bonus: 					int = 0

## This is the flat defend point bonus that entities can have.
var defend_bonus: 					int = 0

## Defense is flat damage reduction on health damage.
var defense: 						int = 0

## Max energy is the number of actions a Game Entity can perform each turn.
var max_energy: 					int

## Current energy is the number of actions a Game Entity can still perform this turn.
var current_energy: 				int

## Borrow limit is the number of Books a Game Entity is allowed to borrow.
## This should only be relevant to Characters, but could become relevant to Enemies?
var borrow_limit: 					int

## Stat used to determine whether or not the

## Name for the category of resisted words/effects.
var resistance_name: 				String = ""

## The words and effects that a GameEntity is resistant to. 
## This includes statuses and other things.
## Format is {word, [value, bonus_type{FLAT, MULT}]}
var resistance_dictionary: 			Dictionary[String, Array] = {}

## Name for the category of vulnerable words/effects.
var weakness_name: 					String = ""

## The words and effects that a GameEntity is weak to.
## This includes statuses and other things.
## Format is {word, [value, bonus_type{FLAT, MULT}]}
var weakness_dictionary: 			Dictionary[String, Array] = {}

## Name for the category of immune effects/words.
## If an enemy gains an immunity from a status, it will NOT show up here.
var immunity_name:					String = ""

## The words and effects that a GameEntity is immnune to.
var immunity_dictionary:			Dictionary[String, Variant] = {}

## The lengths of words that a GameEntity is immune to.
var immune_lengths:					Array[int] = []
#endregion

#region Other Data
## Tag that determines what sort of sound a GameEntity should make.
var flavor_tag = "DEFAULT"

## Is this GameEntity the current target?
var is_target := false

## Does this GameEntity have the initiative to take their turn?
var has_initiative := false

## Enum for actions performed on a GameEntity. Target is a left click, View is a right click.
enum GameEntityAction {
	TARGET, VIEW
}
#endregion

func _ready():
	%EntityHealthBar.max_value = max_health
	update_health_bar()
	target_query()
	%Entity_Button.gui_input.connect(self._on_entity_button_gui_input)
	
	GameEventHandler.apply_status_to_entity.connect(add_status)

## Procedure for what a GameEntity does when its turn starts. Zeroes block, sets energy to current max energy,
## grants itself the initiative, and then emits the turn start signal.
func on_turn_start(count: int):
	self.block = 0
	self.current_energy += self.max_energy
	self.has_initiative = true
	%Entity_Border.modulate = Color(1, 1, 1, 1)
	GameEventHandler.on_turn_start.emit(self, count)
	update_health_bar()

## Procedure for what a GameEntity does when its turn ends. Loses initiative and emits the turn end signal.
func on_turn_end(count: int):
	self.has_initiative = false
	%Entity_Border.modulate = Color(0, 0, 0, 1)
	GameEventHandler.on_turn_end.emit(self, count)
	update_health_bar()

## Function for handling targeting states for a GameEntity. Currently, this only changes a Label.
func target_query():
	print("Updating!")
	if not is_target:
		%TargetLabel.text = "Not the target!"
	
	elif is_target:
		%TargetLabel.text = "im; target"
		
	else:
		%TargetLabel.text = "I don't know what I am!"

## Processor for incoming words. Score-based Weaknesses or Resistances are handled elsewhere.
func process_word_effect(word: String, score_value: int, sender: GameEntity, recipient: GameEntity):
	## Not needed here if resistances/weaknesses/immunities don't account for Status Effects and the like.
	# query_weakness_or_resistance(word, sender, recipient)
	
	GameEventHandler.affected_by_word.emit(sender, recipient, word)
	
	if sender == recipient:
		gain_block(score_value, word)
	else:
		if not sender.get_class() == recipient.get_class():
			take_damage(score_value, word)
			GameEventHandler.thorns_activated.emit(recipient, sender)
		elif sender.get_class() == recipient.get_class():
			## TODO: Implement this better later. This is Enemies interacting with other Enemies.
			## TODO: For right now, this should just give the other Entity Block.
			## IDEA: Pipe it through process_other_effect w/ a special flag?
			recipient.gain_block(score_value, word)

func process_other_effect(source: String, _value: int, sender: GameEntity, recipient: GameEntity):
	## Not needed here if resistances/weaknesses/immunities don't account for Status Effects and the like.
	# query_weakness_or_resistance(source, sender, recipient)
	
	GameEventHandler.affected_by_other.emit(sender, recipient, source)
	
	pass ## TODO: Implement this later. This is likely something internal to the GameEntity, usually an Enemy.

## Function to determine whether or not a word is on a [GameEntity]'s list of weak or resisted words.
func query_weakness_or_resistance(source: String, sender: GameEntity, recipient: GameEntity, finding: bool = false, scoring: bool = false):
	if resistance_dictionary.has(source):
		if scoring:
			resistance_bonus_effect(sender, recipient, source)
			return weakness_dictionary.get(source)
		elif finding:
			return resistance_dictionary.get(source)
		else:
			return null
	
	if weakness_dictionary.has(source):
		if scoring:
			weakness_bonus_effect(sender, recipient, source)
			return weakness_dictionary.get(source)
		elif finding:
			return weakness_dictionary.get(source)
		else:
			return null
	
	else:
		return null

## Function to determine if a [GameEntity] is immune to a word, based on either length or 
func query_immunity(source: String, _sender: GameEntity, _recipient: GameEntity, _finding: bool = false, _scoring: bool = false):
	if immunity_dictionary.has(source):
		return true
	elif not source.begins_with("STATUS_") \
		or not source.begins_with("RELIC_") \
		or not source.begins_with("UNDEFINED_") \
		and immune_lengths.has(source.length()):
		return true
	
	else:
		return false

## Function to be called via super() inside of [Enemy]s and [Character]s when a [GameEntity]'s Weakness is triggered.
func weakness_bonus_effect(sender: GameEntity, recipient: GameEntity, reason: String):
	GameEventHandler.weakness_activated.emit(sender, recipient, reason)

## Function to be called via super() inside of [Enemy]s and [Characters] when a [GameEntity]'s Resistance is triggered.
func resistance_bonus_effect(sender: GameEntity, recipient: GameEntity, reason: String):
	GameEventHandler.resistance_activated.emit(sender, recipient, reason)

func take_damage(damage: int, reason: String = "UNDEFINED_REASON", piercing: bool = false):

	print("Score Received: " + str(damage))
	var sound_flag: String = ""
	
	if self.block > 0:
		self.block -= damage
		sound_flag = "BlockHitLight"
		GameEventHandler.block_lost.emit(clamp(damage, damage, block), self, reason)
		if block < 0:
			var damage_remaining = abs(self.block)
			self.block = 0
			
			var post_reduction_damage
			if not piercing:
				post_reduction_damage = damage_remaining - self.defense
			else:
				post_reduction_damage = damage_remaining
		
			sound_flag = "BlockHitHeavy"
			GameEventHandler.block_broken.emit(self, reason)
			if post_reduction_damage > 0:
				self.health -= post_reduction_damage
				GameEventHandler.take_damage.emit(post_reduction_damage, self, reason)
			else:
				self.health -= 1
				GameEventHandler.take_damage.emit(1, self, reason)

	else:
		var post_reduction_damage
		if not piercing:
			post_reduction_damage = damage - self.defense
		else:
			post_reduction_damage = damage
			
		if post_reduction_damage > 0:
			self.health -= post_reduction_damage
			GameEventHandler.take_damage.emit(post_reduction_damage, self, reason)
			sound_flag = "HitSoundTemp"
		else:
			self.health -= 1
			GameEventHandler.take_damage.emit(1, self, reason)
			sound_flag = "HitSoundTemp"
	
	clamp(self.health, 0, max_health)
	print(str(self.name) + " has taken damage. Reason: " + reason)
	
	GameEventHandler.play_entity_sound.emit(sound_flag, flavor_tag)
	
	# These two could be replaced by signals, but it would be unwieldy.
	update_health_bar()
	check_for_death(reason)

func lose_health(health_loss, reason: String = "UNDEFINED_REASON"):
	self.health -= health_loss
	GameEventHandler.health_lost.emit(health_loss, self, reason)
	
	clamp(self.health, 0, max_health)
	print(str(self.name) + " has lost health. Reason: " + reason)
	
	GameEventHandler.play_entity_sound.emit("HitSoundTemp", flavor_tag)
	
	# These two could be replaced by signals, but it would be unwieldy.
	update_health_bar()
	check_for_death(reason)

func gain_health(healing, reason: String = "UNDEFINED_REASON"):
	if self.health < self.max_health:
		self.health += healing
		
		clamp(self.health, 0, max_health)
		print(str(self.name) + " has gained health. Reason: " + reason)
			
		GameEventHandler.health_gained.emit(healing, self, reason)
		
	update_health_bar()

func gain_block(block_value, reason: String = "UNDEFINED_REASON"):
	self.block += block_value
	GameEventHandler.block_gained.emit(block_value, self, reason)
	print(str(self.name) + " has gained block. Reason: " + reason)
	
	if block_value > 50:
		GameEventHandler.play_entity_sound.emit("BlockGainHeavy", flavor_tag)
	elif not block_value == 0:
		GameEventHandler.play_entity_sound.emit("BlockGainLight", flavor_tag)
	
	update_health_bar()

func check_for_death(reason: String):
	if self.health <= 0:
		GameEventHandler.entity_has_died.emit(self, reason)
		GameEventHandler.play_entity_sound.emit("DeathSound", flavor_tag)
		print(str(self.name) + " has died. Cause of Death: " + reason)

func remove_energy(value: int):
	self.current_energy -= value
	update_health_bar()

func gain_max_health(value: int, reason: String = "UNDEFINED_REASON"):
	self.max_health += value
	
	GameEventHandler.max_health_gained.emit(value, self, reason)
	
	gain_health(value, "ENTITY_Gained Max Health.")
	
	update_health_bar()
	
func gain_max_health_empty(value: int, reason: String = "UNDEFINED_REASON"):
	self.max_health += value
	
	GameEventHandler.max_health_gained.emit(value, self, reason)
	update_health_bar()

## TODO: Change this drastically as part of the status rework.
## add_statues applies a Status to a target, and determines the amount of the status applied, if it decays each turn, and the duration of it.
func add_status(status: String, status_amount: int, status_duration: int, sender: GameEntity, recipient: GameEntity, reason: String = "UNDEFINED_REASON") -> void:
	if recipient == self:
		var new_status = StatusManager._instance_called_status(status)
		%StatusPreProcess.add_child(new_status)
		
		if new_status.status_type == StatusEffect.StatusType.DEBUFF and query_status_value(19) > 0:
			new_status.queue_free()
			GameEventHandler.purity_activated.emit(recipient, sender)
			
		elif new_status.status_type == StatusEffect.StatusType.NEUTRAL and status_amount < 0 and query_status_value(19) > 0:
			new_status.queue_free()
			GameEventHandler.purity_activated.emit(recipient, sender)
			
		else:
			if query_status_value(new_status.status_id) == 0:
				new_status.reparent(%Statuses)
				new_status.inflictor = sender
				new_status.inflicted_entity = recipient
				new_status.on_application(status_amount, status_duration)
				GameEventHandler.status_gained.emit(new_status, recipient, reason)
				
			elif not query_status_value(new_status.status_id) == 0:
				for i in %Statuses.get_child_count():
					var current_status = %Statuses.get_child(i) as StatusEffect
					if current_status.status_id == new_status.status_id:
						current_status.on_stacked(status_amount, status_duration)
		
			else:
				pass
		
	#var new_status = status_dictionary.get(status) 
	#var effect_node = status_effect_scene.instantiate()
	#var _amount = status_amount
	#var status_decay = does_status_decay
	#var _duration = status_duration
	#
	#effect_node.set_script(new_status)
	#%Statuses.add_child(effect_node)
#
	#if effect_node.tile_status == true:
		#var affected_tile_indices = effect_node.on_application(_amount, status_decay, _duration)
		#if affected_tile_indices.size() == 0:
			#effect_node.queue_free()
		#elif %Statuses.get_parent() is Character:
			#GameEventHandler.update_tile_graphics.emit(affected_tile_indices)
			#return
		#elif %Statuses.get_parent() is Enemy:
			#GameEventHandler.update_tile_tooltip_graphics.emit(%Statuses.get_parent(), affected_tile_indices)
			#return
		#else:
			#print("Uh Oh!")
				#
	#if effect_node.tile_status == false and effect_node.stack_type == StatusEffect.StackType.BOTH:
		#for i in %Statuses.get_child_count() - 1:
			#print("Searching 1...")
			#if effect_node.id == %Statuses.get_child(i).id:
				#print("Status found!")
				#%Statuses.get_child(i).amount += _amount
				#%Statuses.get_child(i).duration += _duration
				#%Statuses.get_child(i).update_label()
				#effect_node.queue_free()
				#return
	#
	#if effect_node.tile_status == false and effect_node.stack_type == StatusEffect.StackType.AMOUNT:
		#for i in %Statuses.get_child_count() - 1:
			#print("Searching 2...")
			#if effect_node.id == %Statuses.get_child(i).id:
				#print("Status found!")
				#%Statuses.get_child(i).amount += _amount
				#%Statuses.get_child(i).update_label()
				#effect_node.queue_free()
				#return
				#
	#if effect_node.tile_status == false and effect_node.stack_type == StatusEffect.StackType.DURATION:
		#for i in %Statuses.get_child_count() - 1:
			#print("Searching 3...")
			#if effect_node.id == %Statuses.get_child(i).id:
				#print("Status found!")
				#%Statuses.get_child(i).duration += _duration
				#%Statuses.get_child(i).update_label()
				#effect_node.queue_free()
				#return
	#
	#if effect_node.tile_status == false and effect_node.stack_type == StatusEffect.StackType.NONE:
		#for i in %Statuses.get_child_count() - 1:
			#print("Searching 4...")
			#if effect_node.id == %Statuses.get_child(i).id:
				#print("Status found!")
				#%Statuses.get_child(i).update_label()
				#effect_node.queue_free()
				#return
#
	#else:
		#effect_node.on_application(_amount, status_decay, _duration)
		#print("Could not find status. Applying status.")

## Will this be adjusted? Maybe it should use the status name and not the ID.
func query_status_value(status_id: int):
	for i in %Statuses.get_child_count():
		if %Statuses.get_child(i).status_id == status_id:
			return %Statuses.get_child(i).amount
	
	return 0
	#for i in %Statuses.get_child_count():
		#if %Statuses.get_child(i).id == status_id:
			#return %Statuses.get_child(i).amount
	#return 0

## TODO: Change this drastically as part of the status rework. Might get deleted entirely!
func remove_status_check():
	pass
	#for i in %Statuses.get_child_count():
		#var status_to_check = %Statuses.get_child(i)
		#if status_to_check.duration == 0:
			#if status_to_check.tile_status == true:
				#var affected_tile_indices =  status_to_check.on_duration_expiry()
				#if %Statuses.get_parent() is Character:
					#GameEventHandler.update_tile_graphics.emit(affected_tile_indices)
				#elif %Statuses.get_parent() is Enemy:
					#GameEventHandler.update_tile_tooltip_graphics.emit(%Statuses.get_parent(), affected_tile_indices)
					#
			#else:
				#status_to_check.on_duration_expiry()
			#
			#status_to_check.queue_free()

## TODO: Change this drastically as part of the status rework.
func clear_status_effects():
	pass
	#for i in %Statuses.get_child_count():
		#var status_to_check = %Statuses.get_child(i)
		#status_to_check.duration = 0
		#status_to_check.on_force_clear()
		#remove_status_check()

## TODO: Delete this as part of the status rework. Replace with a signal.
#func update_affected_tiles(affected_tile_indices):
	#if %Statuses.get_parent() is Character:
		#GameEventHandler.update_tile_graphics.emit(affected_tile_indices)
	#elif %Statuses.get_parent() is Enemy:
		#GameEventHandler.update_tile_tooltip_graphics.emit(affected_tile_indices)
	
func update_health_bar(): ## TODO: Animations
	%EntityHealthBar.value = self.health
	%EntityHealthBar.max_value = self.max_health
	%HealthBarLabel.text = str(str(self.health) + "/" + str(self.max_health))
	%BlockLabel.text = str("Block: " + str(self.block))
	%DataLabel.text = str("Energy: " + str(self.current_energy))

func _on_entity_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_target = true
			GameEventHandler.entity_clicked.emit(
				self, GameEntityAction.TARGET
			)
			
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			GameEventHandler.entity_clicked.emit(
				self, GameEntityAction.VIEW
			)

func _on_entity_mouse_entered() -> void:
	GameEventHandler.entity_hovered.emit(self, true)

func _on_entity_mouse_exited() -> void:
	GameEventHandler.entity_hovered.emit(self, false)
