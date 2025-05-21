extends Node
class_name StatusEffect

var duration = 0
var amount = 0

func _ready():
	pass

## When this status is applied, this determines the amount of the status applied, if it decays each turn, and the duration of it.
func on_application(amount: int, does_decay: bool, duration: int):
	pass

## What does this status do at the start of a turn, if anything?
func on_turn_start():
	pass

## What does this status do at the end of a turn, if anything?
func on_turn_end():
	pass

## What does this status do when it expires, if anything?
func on_duration_expiry():
	pass

## What does this status do at the end of combat, if anything?
func on_combat_end():
	pass
