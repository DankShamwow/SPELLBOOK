extends Control
class_name GameEntity

var current_target = GeneralManager.current_target

## The maximum health of the game entity
var max_health: int

## The current health of the game entity
var health: int

## The current block value of the game entity. Damage taken needs to deplete this before
## damage to the entity's current health can be taken.
var block: int

## This is the flat damage bonus that enemies can have.
var attack_bonus: int

## Defense is flat damage reduction on health damage.
var defense: int

## Max energy is the number of actions a Game Entity can perform each turn.
var max_energy: int

## Current energy is the number of actions a Game Entity can still perform this turn.
var current_energy: int

## Is this GameEntity the current target?
var is_target: bool

## Does this GameEntity have the initiative to take their turn?
var has_initiative := false

signal entity_clicked(which: GameEntity, action: GameEntityAction)

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
		update_health_bar()
		
func on_turn_end():
	%Entity_Border.modulate = Color(0, 0, 0, 1)
	update_health_bar()

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
	if self.health < 0:
		print("Oh No! I have died!")

func remove_energy(value: int):
	self.current_energy -= value
	update_health_bar()
		
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
