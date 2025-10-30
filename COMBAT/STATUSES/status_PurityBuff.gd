extends StatusEffect

# Called when the node enters the scene tree for the first time.
func _ready():
	status_id = 19
	status_name = "Purity"
	if amount > 1:
		status_description = str("The next " + str(self.amount) + " negative status effects are nullified.")
	else:
		status_description = str("The next negative status effect is nullified.")
	stack_type = StackType.INDEFINITE
	tick_type = TickType.TURN_END
	status_type = StatusType.BUFF
	
	GameEventHandler.purity_activated.connect(on_purity_activated)
	
	super()

func _update_graphics():
	status_name = "Purity"
	if amount > 1:
		status_description = str("The next " + str(self.amount) + " negative status effects are nullified.")
	else:
		status_description = str("The next negative status effect is nullified.")
	super()
	
func on_application(status_amount: int, _status_duration: int = 0):
	amount = status_amount
	duration = _status_duration
	_update_graphics()
	
	if amount <= 0:
		on_duration_expiry()
	
func on_stacked(status_amount: int, _status_duration: int = 0):
	amount += status_amount
	
	_update_graphics()
	
	if amount <= 0:
		on_duration_expiry()

func on_purity_activated(purity_owner: GameEntity, _inflictor: GameEntity):
	if inflicted_entity == purity_owner:
		amount -= 1
	
		_update_graphics()
	
		if amount <= 0:
			on_duration_expiry()

func on_duration_expiry():
	self.queue_free()
