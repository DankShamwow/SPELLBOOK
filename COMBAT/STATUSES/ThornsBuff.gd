extends StatusEffect
class_name ThornsBuff

func _ready():
	id = 11
	status_name = "Thorns"
	status_description = str("Attackers take " + str(self.amount) + " damage in return when they attack.")
	tile_status = false
	print("STATUS ID: " + str(id))
	stack_type = StatusEffect.StackType.AMOUNT
	super()

func _update_graphics():
	status_name = "Thorns"
	status_description = str("Attackers take " + str(self.amount) + " damage in return when they attack.")
	super()
	
func _on_status_effect_mouse_entered():
	status_description = str("Attackers take " + str(self.amount) + " damage in return when they attack.")
	super()

## When this status is applied, this determines the amount of the status applied, if it decays each turn, and the duration of it.
func on_application(status_amount: int, does_status_decay: bool, status_duration: int):
	print("Attempting to apply status...")
	
	if does_status_decay:
		does_decay = true
		amount = status_amount
		duration = status_duration
		%NumberLabel.text = str(duration)
		
	if not does_status_decay:
		amount = status_amount
		duration = 1
		%NumberLabel.text = str(amount)

func on_turn_start():
	if does_decay:
		duration -= 1
		%NumberLabel.text = str(duration)
		
	if duration == 0:
		on_duration_expiry()

func on_duration_expiry():
	amount = 0
	duration = 0

func on_combat_end():
	on_duration_expiry()

func on_force_clear():
	on_duration_expiry()
