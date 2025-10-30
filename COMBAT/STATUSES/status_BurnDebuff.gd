extends StatusEffect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	status_id = 7
	status_name = "Burn"
	status_description = str("At the end of turn, takes " + str(self.amount) + " damage and loses 1 stack of Burn. Mitigated by Block.")
	stack_type = StackType.DECREASE_OVER_TIME
	tick_type = TickType.TURN_END
	status_type = StatusType.DEBUFF
	super()

func _update_graphics():
	status_name = "Burn"
	status_description = str("At the end of turn, takes " + str(self.amount) + " damage and loses 1 stack of Burn. Mitigated by Block.")
	super()

func on_application(status_amount: int, _status_duration: int = 0):
	amount = status_amount
	duration = status_amount
	
	_update_graphics()

func on_turn_end(which: GameEntity, _count: int):
	if which == inflicted_entity:
		inflicted_entity.take_damage(amount, "STATUS_BurnDebuff", true)
		amount -= 1
		
		_update_graphics()
		
		if amount <= 0:
			on_duration_expiry()
		
func on_duration_expiry():
	self.queue_free()
