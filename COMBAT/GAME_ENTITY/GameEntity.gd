extends Control
class_name GameEntity

@export_group("Text")
@export var entity_name: String
@export_multiline var entity_description: String

var current_target = GeneralManager.current_target

var status_dictionary = StatusDictionary.StatusEffectList
var status_effect_scene: PackedScene = preload("res://COMBAT/STATUSES/StatusEffect.tscn")

## The maximum health of the game entity
var max_health: int

## The current health of the game entity
var health: int

## The current block value of the game entity. Damage taken needs to deplete this before
## damage to the entity's current health can be taken.
var block := 0

## This is the flat damage bonus that enemies can have.
var attack_bonus: int

## Defense is flat damage reduction on health damage.
var defense: int

## Max energy is the number of actions a Game Entity can perform each turn.
var max_energy: int

## Current energy is the number of actions a Game Entity can still perform this turn.
var current_energy: int

## Is this GameEntity the current target?
var is_target := false

## Does this GameEntity have the initiative to take their turn?
var has_initiative := false

signal entity_clicked(which: GameEntity, action: GameEntityAction)
signal entity_has_died(which: GameEntity)
signal update_tile_graphics()
signal update_tooltip_tile_graphics()

enum GameEntityAction {
	TARGET, VIEW
}

func _ready():
	update_health_bar()
	target_query()
	%Entity_Button.gui_input.connect(self._on_entity_button_gui_input)
	
func on_turn_start():
	if has_initiative:
		self.block = 0
		%Entity_Border.modulate = Color(1, 1, 1, 1)
		self.current_energy += self.max_energy
		
		for i in %Statuses.get_child_count():
			var affected_tile_indices = %Statuses.get_child(i).on_turn_start()
			if affected_tile_indices:
				update_affected_tiles(affected_tile_indices)
		
		update_health_bar()
		remove_status_check()

func on_turn_end():
	for i in %Statuses.get_child_count():
		var affected_tile_indices = %Statuses.get_child(i).on_turn_end()
		if affected_tile_indices:
			update_affected_tiles(affected_tile_indices)
	
	
	%Entity_Border.modulate = Color(0, 0, 0, 1)
	update_health_bar()
	remove_status_check()

func target_query():
	print("Updating!")
	if not is_target:
		%TargetLabel.text = "Not the target!"
	
	elif is_target:
		%TargetLabel.text = "im; target"
		
	else:
		%TargetLabel.text = "I don't know what I am!"

func take_damage(damage):

	print("Score Received:" + str(damage))

	if self.block > 0:
		self.block -= damage
		if block < 0:
			var damage_remaining = abs(self.block)
			self.block = 0
			var post_reduction_damage = damage_remaining - self.defense
			if post_reduction_damage > 0:
				self.health -= post_reduction_damage
			else:
				self.health -= 1

	else:
		var post_reduction_damage = damage - self.defense
		if post_reduction_damage > 0:
			self.health -= post_reduction_damage
		else:
			self.health -= 1
		
	print(damage)
	update_health_bar()
	check_for_death()

func lose_health(health_loss):
	self.health -= health_loss

func gain_health(healing):
	if self.health < self.max_health:
		self.health += healing
		if self.health > self.max_health:
			self.health = self.max_health
	update_health_bar()

func gain_block(block_value):
	self.block += block_value
	update_health_bar()

func check_for_death():
	if self.health <= 0:
		entity_has_died.emit(self)

func remove_energy(value: int):
	self.current_energy -= value
	update_health_bar()

## add_statues applies a Status to a target, and determines the amount of the status applied, if it decays each turn, and the duration of it.
func add_status(status: String, status_amount: int, does_status_decay: bool, status_duration: int) -> void:

	var new_status = status_dictionary.get(status)
	var effect_node = status_effect_scene.instantiate()
	var _amount = status_amount
	var status_decay = does_status_decay
	var _duration = status_duration
	
	effect_node.set_script(new_status)
	%Statuses.add_child(effect_node)

	if effect_node.tile_status == true:
		var affected_tile_indices = effect_node.on_application(_amount, status_decay, _duration)
		if affected_tile_indices.size() == 0:
			effect_node.queue_free()
		elif %Statuses.get_parent() is Character:
			update_tile_graphics.emit(affected_tile_indices)
			return
		elif %Statuses.get_parent() is Enemy:
			update_tooltip_tile_graphics.emit(affected_tile_indices)
			return
		else:
			print("Uh Oh!")
	
	if effect_node.tile_status == false and effect_node.stack_type == StatusEffect.StackType.BOTH:
		for i in %Statuses.get_child_count() - 1:
			print("Searching 1...")
			if effect_node.id == %Statuses.get_child(i).id:
				print("Status found!")
				%Statuses.get_child(i).amount += _amount
				%Statuses.get_child(i).duration += _duration
				%Statuses.get_child(i).update_label()
				effect_node.queue_free()
				return
				
	if effect_node.tile_status == false and effect_node.stack_type == StatusEffect.StackType.AMOUNT:
		for i in %Statuses.get_child_count() - 1:
			print("Searching 2...")
			if effect_node.id == %Statuses.get_child(i).id:
				print("Status found!")
				%Statuses.get_child(i).amount += _amount
				%Statuses.get_child(i).update_label()
				effect_node.queue_free()
				return
				
	if effect_node.tile_status == false and effect_node.stack_type == StatusEffect.StackType.DURATION:
		for i in %Statuses.get_child_count() - 1:
			print("Searching 3...")
			if effect_node.id == %Statuses.get_child(i).id:
				print("Status found!")
				%Statuses.get_child(i).duration += _duration
				%Statuses.get_child(i).update_label()
				effect_node.queue_free()
				return
	
	if effect_node.tile_status == false and effect_node.stack_type == StatusEffect.StackType.NONE:
		for i in %Statuses.get_child_count() - 1:
			print("Searching 4...")
			if effect_node.id == %Statuses.get_child(i).id:
				print("Status found!")
				%Statuses.get_child(i).update_label()
				effect_node.queue_free()
				return

	else:
		effect_node.on_application(_amount, status_decay, _duration)
		print("Could not find status.")

func query_status_value(status_id: int):
	for i in %Statuses.get_child_count():
		if %Statuses.get_child(i).id == status_id:
			return %Statuses.get_child(i).amount

func remove_status_check():
	for i in %Statuses.get_child_count():
		var status_to_check = %Statuses.get_child(i)
		if status_to_check.duration == 0:
			if status_to_check.tile_status == true:
				var affected_tile_indices =  status_to_check.on_duration_expiry()
				if %Statuses.get_parent() is Character:
					update_tile_graphics.emit(affected_tile_indices)
				elif %Statuses.get_parent() is Enemy:
					update_tooltip_tile_graphics.emit(affected_tile_indices)
					
			else:
				status_to_check.on_duration_expiry()
			
			status_to_check.queue_free()

func clear_status_effects():
	for i in %Statuses.get_child_count():
		var status_to_check = %Statuses.get_child(i)
		status_to_check.duration = 0
		status_to_check.on_force_clear()
		remove_status_check()

func update_affected_tiles(affected_tile_indices):
	if %Statuses.get_parent() is Character:
		update_tile_graphics.emit(affected_tile_indices)
	elif %Statuses.get_parent() is Enemy:
		update_tooltip_tile_graphics.emit(affected_tile_indices)
	
func update_health_bar():
	%EntityHealthBar.value = self.health
	%HealthBarLabel.text = str(str(self.health) + "/" + str(self.max_health))
	%BlockLabel.text = str("Block: " + str(self.block))
	%DataLabel.text = str("Energy: " + str(self.current_energy))

func _on_entity_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Left Clunkety!")
			is_target = true
			entity_clicked.emit(
				self, GameEntityAction.TARGET
			)
			
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("Right Clunkety!")
			entity_clicked.emit(
				self, GameEntityAction.VIEW
			)
