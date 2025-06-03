extends StatusEffect
class_name BurnDebuff

func _ready():
	id = 5
	tile_status = false
	stack_type = StatusEffect.StackType.BOTH
	print("STATUS ID: " + str(id))
	super()

## When this status is applied, this determines the amount of the status applied, if it decays each turn, and the duration of it.
func on_application(status_amount: int, does_status_decay: bool, status_duration: int):
	
	# This status should ALWAYS decay, but if not we'll have a handler for it regardless.
	if does_status_decay:
		does_decay = true
		amount = status_amount
		duration = status_duration
		%NumberLabel.text = str(amount)
		
	if not does_status_decay:
		amount = status_amount
		duration = 1
		%NumberLabel.text = ""

func update_label():
	%NumberLabel.text = str(amount)

## What does this status do at the end of a turn, if anything?
func on_turn_end():
	var parent = self.get_parent().get_parent()
	if parent.block > 0:
		parent.block -= amount
		if parent.block < 0:
			var amount_remaining = abs(parent.block)
			parent.block = 0
			parent.lose_health(amount_remaining)
			amount -= 1
			
	
	else:
		parent.lose_health(amount)
		amount -= 1
	
	%NumberLabel.text = str(amount)
	
	if amount == 0:
		duration = 0

func on_duration_expiry():
	amount = 0
	duration = 0
	
func on_force_clear():
	on_duration_expiry()
