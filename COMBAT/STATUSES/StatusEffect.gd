extends Control
class_name StatusEffect

enum StackType {NONE, AMOUNT, DURATION, BOTH}

@export var id := -1
@export var stack_type: StackType
@export var does_decay:= false
@export var has_icon := true
@export var tile_status := false
@export var duration := 0
@export var amount := 0

func _ready():
	%Icon.set_frame_coords(Vector2i(id % 10, floor(id / 10)))
	%NumberLabel.text = ""

func _update_graphics():
	%Icon.set_frame_coords(Vector2i(id % 10, floor(id / 10)))
	if does_decay:
		%NumberLabel.text = str(amount)

	if not does_decay:
		%NumberLabel.text = ""

## When this status is applied, this determines the amount of the status applied, if it decays each turn, and the duration of it.
func on_application(status_amount: int, does_status_decay: bool, status_duration: int):
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

func on_force_clear():
	pass

## What does this status do when its parent dies, if anything?
func on_parent_death():
	pass

func update_label():
	pass
