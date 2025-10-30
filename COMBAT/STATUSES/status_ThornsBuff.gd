extends StatusEffect

# Called when the node enters the scene tree for the first time.
func _ready():
	status_id = 15
	status_name = "Thorns"
	status_description = str("Attackers take " + str(self.amount) + " damage in return when they attack.")
	stack_type = StackType.INDEFINITE
	tick_type = TickType.NONE
	status_type = StatusType.BUFF
	
	GameEventHandler.thorns_activated.connect(on_thorns_activated)
	
	super()

func _update_graphics():
	status_name = "Thorns"
	status_description = str("Attackers take " + str(self.amount) + " damage in return when they attack.")
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

func on_thorns_activated(thorns_owner: GameEntity, attacker: GameEntity):
	if inflicted_entity == thorns_owner:
		attacker.take_damage(amount, "STATUS_ThornsBuff")

func on_duration_expiry():
	self.queue_free()
