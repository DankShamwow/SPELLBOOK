extends StatusEffect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	status_id = 8
	status_name = "Poison"
	status_description = str("At the start of turn, loses " + str(self.amount) + " health and 1 stack of Poison.")
	stack_type = StackType.DECREASE_OVER_TIME
	tick_type = TickType.TURN_START
	status_type = StatusType.DEBUFF
	super()

func _update_graphics():
	status_name = "Poison"
	status_description = str("At the start of turn, loses " + str(self.amount) + " health and 1 stack of Poison.")
	super()

func on_application(status_amount: int, _status_duration: int = 0):
	amount = status_amount
	duration = status_amount
	
	_update_graphics()

func on_turn_start(which: GameEntity, _count: int):
	if which == inflicted_entity:
		inflicted_entity.take_damage(amount, "STATUS_PoisonDebuff")
		amount -= 1
		
		_update_graphics()
		
		if amount <= 0:
			on_duration_expiry()
		
func on_duration_expiry():
	self.queue_free()
