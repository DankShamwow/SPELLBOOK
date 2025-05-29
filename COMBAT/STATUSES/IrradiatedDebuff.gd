extends StatusEffect
class_name IrradiatedDebuff

func _ready():
	id = 8
	stack_type = StatusEffect.StackType.AMOUNT
	print("STATUS ID: " + str(id))
	super()

## When this status is applied, this determines the amount of the status applied, if it decays each turn, and the duration of it.
func on_application(status_amount: int, does_status_decay: bool, status_duration: int):
	
	# This status should NEVER decay, but if we for some reason need it to, we'll have a handler for it regardless.
	if does_status_decay:
		does_decay = true
		amount = status_amount
		duration = status_duration
		%NumberLabel.text = str(amount)
		
	if not does_status_decay:
		does_decay = false
		amount = status_amount
		duration = 1
		%NumberLabel.text = str(amount)

func update_label():
	%NumberLabel.text = str(amount)

## What does this status do at the end of a turn, if anything?
func on_turn_start():
	%NumberLabel.text = str(amount)
	var parent = self.get_parent().get_parent()
	parent.lose_health(amount)

func on_duration_expiry():
	return
