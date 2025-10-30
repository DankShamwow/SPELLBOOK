extends StatusEffect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	status_id = 9
	status_name = "Bleed"
	status_description = str("At the start and end of turn, loses " + str(self.amount) + " health. Loses 1 stack of Bleed at the end of turn.")
	stack_type = StackType.DECREASE_OVER_TIME
	tick_type = TickType.TURN_START_END
	status_type = StatusType.DEBUFF
	super()

func _update_graphics():
	status_name = "Bleed"
	status_description = str("At the start and end of turn, loses " + str(self.amount) + " health. Loses 1 stack of Bleed at the end of turn.")
	super()

func on_application(status_amount: int, _status_duration: int = 0):
	amount = status_amount
	duration = status_amount
	
	_update_graphics()

func on_turn_start(which: GameEntity, _count: int):
	if which == inflicted_entity:
		inflicted_entity.take_damage(amount, "STATUS_BleedDebuff")
		
func on_turn_end(which: GameEntity, _count: int):
	if which == inflicted_entity:
		inflicted_entity.take_damage(amount, "STATUS_BleedDebuff")
		amount -= 1
		
		_update_graphics()
		
		if amount <= 0:
			on_duration_expiry()
		
func on_duration_expiry():
	self.queue_free()
