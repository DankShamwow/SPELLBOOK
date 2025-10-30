extends StatusEffect

func _ready():
	status_id = 14
	status_name = "Armor"
	if amount >= 1:
		status_description = str("Takes " + str(self.amount) + " less damage from Words.")
	else:
		status_description = str("Takes " + str(abs(self.amount)) + " more damage from Words")
	stack_type = StackType.INDEFINITE
	tick_type = TickType.NONE
	status_type = StatusType.NEUTRAL
	super()

func _update_graphics():
	status_name = "Armor"
	if amount >= 1:
		status_description = str("Takes " + str(self.amount) + " less damage from Words.")
	else:
		status_description = str("Takes " + str(abs(self.amount)) + " more damage from Words")
	super()

func on_application(status_amount: int, _status_duration: int = 0):
	amount = status_amount
	duration = _status_duration
	inflicted_entity.attack_bonus += amount
	
	if amount > 0:
		status_type = StatusType.BUFF
	elif amount < 0:
		status_type = StatusType.DEBUFF
	else:
		status_type = StatusType.NEUTRAL
	
	_update_graphics()
	

func on_stacked(status_amount: int, _status_duration: int = 0):
	inflicted_entity.attack_bonus += status_amount
	amount += status_amount
	
	_update_graphics()
	
	if amount == 0:
		on_duration_expiry()

func on_duration_expiry():
	inflicted_entity.attack_bonus -= amount
	self.queue_free()
