extends StatusEffect

func _ready():
	status_id = 13
	status_name = "Intelligence"
	if amount > 1:
		status_description = str("Words are treated as though they have " + str(self.amount) + " additional tiles.")
	elif amount == 1:
		status_description = str("Words are treated as though they have " + str(self.amount) + " additional tile.")
	elif amount == -1:
		status_description = str("Words are treated as though they have " + str(abs(self.amount)) + " less tile.")
	else:
		status_description = str("Words are treated as though they have " + str(abs(self.amount)) + " fewer tiles.")
	stack_type = StackType.INDEFINITE
	tick_type = TickType.NONE
	status_type = StatusType.NEUTRAL
	super()

func _update_graphics():
	status_name = "Intelligence"
	if amount > 1:
		status_description = str("Words are treated as though they have " + str(self.amount) + " additional tiles.")
	elif amount == 1:
		status_description = str("Words are treated as though they have " + str(self.amount) + " additional tile.")
	elif amount == -1:
		status_description = str("Words are treated as though they have " + str(abs(self.amount)) + " less tile.")
	else:
		status_description = str("Words are treated as though they have " + str(abs(self.amount)) + " fewer tiles.")
	super()

func on_application(status_amount: int, _status_duration: int = 0):
	amount = status_amount
	duration = _status_duration
	inflicted_entity.length_bonus += amount
	
	if amount > 0:
		status_type = StatusType.BUFF
	elif amount < 0:
		status_type = StatusType.DEBUFF
	else:
		status_type = StatusType.NEUTRAL
	
	_update_graphics()

func on_stacked(status_amount: int, _status_duration: int = 0):
	inflicted_entity.length_bonus += status_amount
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
	inflicted_entity.length_bonus -= amount
	self.queue_free()
