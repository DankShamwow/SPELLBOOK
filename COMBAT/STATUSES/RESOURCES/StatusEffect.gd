extends Control
class_name StatusEffect

## StackType determines how stacking is handled for the status effect.
enum StackType 	{	
					## Stacking increases the amount and duration of the status. Amount and duration are equal.
					DECREASE_OVER_TIME = 0,
					## Stacking adds a new instance of the status with its own duration.
					TIMED_EXPIRY = 1,
					## Can be stacked. Stacking increases the amount of the status, but not the duration which is set with the initial application of the status.
					TIMED_PAYOFF = 2,
					## Can be stacked and does not decay over time.
					INDEFINITE = 3,
					## Cannot be stacked and lasts indefinitely.
					UNIQUE = 4
				}

## TickType determines how a status's duration or amount will change each turn.
enum TickType	{	
					## Status is not affected by the passing of turns.
					NONE = 0,
					## Status has an effect or timer that activates at the start of the turn.
					TURN_START = 1,
					## Status has an effect or timer that activates at the end of the turn.
					TURN_END = 2,
					## Status has an effect or timer that activates at both the start and end of the turn.
					TURN_START_END = 3
				}

enum StatusType	{
					## Status is neither positive or negative.
					NEUTRAL = 0,
					## Status is a positive effect.
					BUFF = 1,
					## Status is a negative effect.
					DEBUFF = 2
				}

## The ID of this StatusEffect.
@export var status_id:= 			-1
## The StackType that this StatusEffect has.
@export var stack_type: 			StackType
## The TickType that this StatusEffect has.
@export var tick_type:				TickType
## The StatusType that this StatusEffect has.
@export var status_type:			StatusType
## Whether or not this StatusEffect has an icon. Defaults to true.
@export var has_icon:=	 			true
## The current duration of this StatusEffect.
@export var duration: 				int
## The current amount of this StatusEffect.
@export var amount: 				int
## The name of this StatusEffect to be used in tooltips and instancing this StatusEffect.
@export var status_name:= 			""
## The description of this StatusEffect to be used in tooltips.
@export var status_description:= 	""

## Who caused this StatusEffect to be added to this GameEntity?
var inflictor: 						GameEntity
## Who is the owner of this StatusEffect? This is effectively a shorthand for self.get_parent().get_parent()
var inflicted_entity:				GameEntity

func _ready():
	%Icon.set_frame_coords(Vector2i(status_id % 10, floor(status_id / 10.0)))
	%NumberLabel.text = ""
	%NumberLabel2.text = ""
	
	GameEventHandler.on_turn_start.connect(self.on_turn_start)
	GameEventHandler.on_turn_end.connect(self.on_turn_end)
	
	GameEventHandler.word_found.connect(self.on_word_found)
	GameEventHandler.word_scored.connect(self.on_word_scored)
	
	GameEventHandler.tile_scored.connect(self.on_tile_scored)
	
	GameEventHandler.relic_activated.connect(self.on_relic_activated)
	
	GameEventHandler.affected_by_word.connect(self.on_entity_affected_by_word)
	GameEventHandler.entity_targeted.connect(self.on_entity_targeted)
	GameEventHandler.weakness_activated.connect(self.on_weakness_activated)
	GameEventHandler.resistance_activated.connect(self.on_resistance_activated)
	GameEventHandler.block_gained.connect(self.on_block_gained)
	GameEventHandler.block_lost.connect(self.on_block_lost)
	GameEventHandler.block_broken.connect(self.on_block_broken)
	GameEventHandler.take_damage.connect(self.on_damage_taken)
	GameEventHandler.health_gained.connect(self.on_health_gained)
	GameEventHandler.health_lost.connect(self.on_health_lost)
	GameEventHandler.entity_has_died.connect(self.on_entity_killed)

func _update_graphics():
	%Icon.set_frame_coords(Vector2i(status_id % 10, floor(status_id / 10.0)))
	
	if stack_type == StackType.DECREASE_OVER_TIME or stack_type == StackType.INDEFINITE:
		%NumberLabel.text = str(amount)
		
	elif stack_type == StackType.TIMED_EXPIRY or stack_type == StackType.TIMED_PAYOFF:
		%NumberLabel.text = str(duration)
		%NumberLabel2.text = str(amount)
	
	elif stack_type == StackType.UNIQUE:
		%NumberLabel.text = ""
		%NumberLabel2.text = ""

func _on_status_effect_mouse_entered():
	GameEventHandler.status_hovered.emit(self, true)
	
func _on_status_effect_mouse_exited():
	GameEventHandler.status_hovered.emit(self, false)

## When this status is applied, this determines what happens, the amount of the status applied, if it decays each turn, and the duration of it.
func on_application(_status_amount: int, _status_duration: int = 0):
	pass

## When this status needs to be stacked via another application of the status, what happens?
func on_stacked(status_amount: int, status_duration: int = 0):
	if stack_type == StackType.UNIQUE or stack_type == StackType.TIMED_EXPIRY:
		pass
		
	elif stack_type == StackType.TIMED_PAYOFF or stack_type == StackType.INDEFINITE:
		amount += status_amount
		
	elif stack_type == StackType.DECREASE_OVER_TIME:
		amount += status_amount
		duration += status_duration
		
		if amount < 0:
			on_duration_expiry()
		
	else:
		pass
	
	_update_graphics()
	
#region Turns

## What does this status do at the start of a turn, if anything?
func on_turn_start(_which: GameEntity, _count: int):
	if tick_type == TickType.TURN_START or tick_type == TickType.TURN_START_END:
		pass ## Put code of effect in here

## What does this status do at the end of a turn, if anything?
func on_turn_end(_which: GameEntity, _count: int):
	if tick_type == TickType.TURN_END or tick_type == TickType.TURN_START_END:
		pass ## Put code of effect in here
	
#endregion
	
#region Word

## What does this status do when a Word is found?
func on_word_found(_word: String, _sender: GameEntity, _recipient: GameEntity):
	pass

## What does this status do when a Word is scored?
func on_word_scored(_word: String, _sender: GameEntity, _recipient: GameEntity):
	pass

#endregion

#region Tiles

## What does this status do when a Tile is scored?
func on_tile_scored(_which: GridTile, _count: int):
	pass

#endregion

#region Relics

## What does this status do when a Relic activates?
func on_relic_activated(_which: Relic):
	pass

#endregion

#region Entity Related

## What does this status do when its owner is affected by a word?
func on_entity_affected_by_word(_word: String, _score_value: int, _sender: GameEntity, _recipient: GameEntity):
	pass

func on_entity_targeted(_who: GameEntity):
	pass

## What does this status do when its owner's weakness is activated by an effect?
func on_weakness_activated(_reason: String):
	pass

## What does this status do when its owner's resistance is activated by an effect?
func on_resistance_activated(_reason: String):
	pass

## What does this status do when its owner gains block?
func on_block_gained(_quantity: int, _who: GameEntity, _reason: String):
	pass

## What does this status do when its owner is hit and still has block remaining?
func on_block_lost(_quantity: int, _who: GameEntity, _reason: String):
	pass

## What does this status do when its owner loses all of its block?
func on_block_broken(_who: GameEntity, _reason: String):
	pass

## What does this status do when its owner takes health damage?
func on_damage_taken(_quantity: int, _who: GameEntity, _reason: String):
	pass
	
## What does this status do when its owner gains health?
func on_health_gained(_quantity: int, _who: GameEntity, _reason: String):
	pass

## What does this status do when its owner loses health?
func on_health_lost(_quantity: int, _who: GameEntity, _reason: String):
	pass

## What does this status do when a GameEntity is killed?
func on_entity_killed(_who: GameEntity, _reason: String):
	pass

#endregion

#region Management

## What does this status do when it expires, if anything?
func on_duration_expiry():
	pass

## What does this status do at the end of combat, if anything?
func on_combat_end():
	on_duration_expiry()

func on_force_clear():
	on_duration_expiry()

#endregion
