extends StatusEffect

# Called when the node enters the scene tree for the first time.
func _ready():
	status_id = 17
	status_name = "Plated Armor"
	status_description = str("Gains " + str(self.amount) + " block at the end of each turn. Reduced by 1 when unblocked attack damage is taken.")
	stack_type = StackType.INDEFINITE
	tick_type = TickType.TURN_END
	status_type = StatusType.BUFF
	super()

func _update_graphics():
	status_name = "Plated Armor"
	status_description = str("Gains " + str(self.amount) + " block at the end of each turn. Reduced by 1 when unblocked attack damage is taken.")
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

func on_health_lost(_quantity: int, who: GameEntity, reason: String):
	if inflicted_entity == who:
		if not reason.begins_with("STATUS_") \
		or not reason.begins_with("RELIC_") \
		or not reason.begins_with("UNDEFINED_"):
			amount -= 1
			
			_update_graphics()
	
			if amount <= 0:
				on_duration_expiry()

func on_turn_end(which: GameEntity, _count: int):
	if inflicted_entity == which:
		inflicted_entity.gain_block(amount, "STATUS_PlatedArmorBuff")

func on_duration_expiry():
	self.queue_free()
