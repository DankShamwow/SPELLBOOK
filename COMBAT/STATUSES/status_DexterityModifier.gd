extends StatusEffect

func _ready():
	status_id = 12
	status_name = "Dexterity"
	if amount > 1:
		status_description = str("Tiles are granted " + str(self.amount) + " additional points when used to defend.")
	elif amount == 1:
		status_description = str("Tiles are granted " + str(self.amount) + " additional point when used to defend.")
	elif amount == -1:
		status_description = str("Tiles are granted " + str(abs(self.amount)) + " less point when used to defend.")
	else:
		status_description = str("Tiles are granted " + str(abs(self.amount)) + " less points when used to defend.")
	stack_type = StackType.INDEFINITE
	tick_type = TickType.NONE
	status_type = StatusType.NEUTRAL
	super()

func _update_graphics():
	status_name = "Dexterity"
	if amount > 1:
		status_description = str("Tiles are granted " + str(self.amount) + " additional points when used to defend.")
	elif amount == 1:
		status_description = str("Tiles are granted " + str(self.amount) + " additional point when used to defend.")
	elif amount == -1:
		status_description = str("Tiles are granted " + str(abs(self.amount)) + " less point when used to defend.")
	else:
		status_description = str("Tiles are granted " + str(abs(self.amount)) + " less points when used to defend.")
	super()

func on_application(status_amount: int, _status_duration: int = 0):
	amount = status_amount
	duration = _status_duration
	inflicted_entity.defend_bonus += amount
	
	if amount > 0:
		status_type = StatusType.BUFF
	elif amount < 0:
		status_type = StatusType.DEBUFF
	else:
		status_type = StatusType.NEUTRAL
	
	_update_graphics()

func on_stacked(status_amount: int, _status_duration: int = 0):
	inflicted_entity.defend_bonus += status_amount
	amount += status_amount
	
	if amount > 0:
		status_type = StatusType.BUFF
	elif amount < 0:
		status_type = StatusType.DEBUFF
	else:
		status_type = StatusType.NEUTRAL
	
	_update_graphics()
	
	if amount == 0:
		on_duration_expiry()

func on_duration_expiry():
	inflicted_entity.defend_bonus -= amount
	self.queue_free()
