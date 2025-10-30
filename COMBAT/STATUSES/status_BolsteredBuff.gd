extends StatusEffect

# Called when the node enters the scene tree for the first time.
func _ready():
	status_id = 16
	status_name = "Bolstered"
	status_description = str("Gains " + str(self.amount) + " block at the end of each turn.")
	stack_type = StackType.INDEFINITE
	tick_type = TickType.TURN_END
	status_type = StatusType.BUFF
	super()

func _update_graphics():
	status_name = "Bolstered"
	status_description = str("Gains " + str(self.amount) + " block at the end of each turn.")
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

func on_turn_end(which: GameEntity, _count: int):
	if inflicted_entity == which:
		inflicted_entity.gain_block(amount, "STATUS_BolsteredBuff")

func on_duration_expiry():
	self.queue_free()
