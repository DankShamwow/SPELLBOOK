extends Control
## NotchPack is only ever used in Shops as a way of allowing the player to get more Notches outside of events and combat.
class_name NotchPack

enum NotchPackType {COMMON, UNCOMMON, RARE, REPEATING, ECHOING, VAPORIZING, WEIGHTED, INERT, GILDED, PHANTOM, FLAMING, REJUVENATING, REINFORCED, EAGER, PATIENT, QUICK, OVERLOADED, BALANCED, LOCAL, DISTANT, PRICKLY, POTENT, LEXICAL}
enum NotchPackAction {FIDGET, VIEW}

var hovering: bool = false

var various_rng = RandomnessManager.various_rng

var scale_tween: Tween
var grumble_tween: Tween

var purchase_price: int = 0

var pack_type: NotchPackType = NotchPackType.COMMON
var pack_size: int = 0
var pack_contents: Array = []

@onready var sprite = %NotchPackSprite
	
func _ready() -> void:
	sprite.set_frame_coords(Vector2i(pack_type, 0))

func _update_graphics():
	sprite.set_frame_coords(Vector2i(pack_type, 0))

func _process(_delta: float) -> void:
	if get_viewport().has_focus():
		if not GeneralManager.scoring_is_active and not scale_tween and not hovering and not scale == is_at_scale():
			determine_object_scale()
		
		if not scale_tween == null:
			if not GeneralManager.scoring_is_active and not scale_tween.is_valid() and not scale_tween.is_running() and not hovering and not scale == is_at_scale():
				determine_object_scale()

func is_at_scale():
	var scaling_factor = 1.0
	if hovering:
		scaling_factor = 1.1
	else:
		scaling_factor = 1.0
			
	var scalar = Vector2(scaling_factor, scaling_factor)
	
	return scalar

func determine_object_scale(speed: float = 0.1):
	var scaling_factor: float = 1.0
	if hovering:
		scaling_factor = 1.1
	else:
		scaling_factor = 1.0

	scale_tween = get_tree().create_tween()
	scale_tween.tween_property(self, "scale", Vector2(scaling_factor, scaling_factor), speed)
	await get_tree().create_timer(speed).timeout

func _on_notch_pack_button_mouse_entered() -> void:
	hovering = true
	determine_object_scale(0.075)
	GameEventHandler.notch_pack_hovered.emit(self, true)
	
func _on_notch_pack_button_mouse_exited() -> void:
	hovering = false
	determine_object_scale()
	GameEventHandler.notch_pack_hovered.emit(self, false)

func _on_notch_pack_button_gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				#print("Left Clackety!")
				GameEventHandler.notch_pack_clicked.emit(
					self, NotchPackAction.FIDGET
				)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				#print("Right Clackety!")
				GameEventHandler.notch_pack_clicked.emit(
					self, NotchPackAction.VIEW
				)

func grumble_object():
	if not grumble_tween:
		var current_position = self.position
		grumble_tween = get_tree().create_tween()
		scale_tween = get_tree().create_tween()
		var tween = get_tree().create_tween()
		
		tween.tween_property(self, "modulate", Color(0.35, 0.0, 0.0, 1.0), 0.01)
		tween.tween_interval(0.13)
		scale_tween.tween_property(self, "scale", self.scale * 0.75, 0.03)
		scale_tween.tween_callback(determine_object_scale.bind(0.03)).set_delay(0.08)
		var grumble_order = various_rng.randi_range(0, 1)
		
		if grumble_order == 0:
			grumble_tween.tween_property(self, "position", Vector2(current_position.x - various_rng.randf_range(1, 8), current_position.y - various_rng.randf_range(1, 8)), 0.05)
			grumble_tween.tween_property(self, "position", Vector2(current_position.x + various_rng.randf_range(1, 8), current_position.y + various_rng.randf_range(1, 8)), 0.05)
		
		if grumble_order == 1:
			grumble_tween.tween_property(self, "position", Vector2(current_position.x + various_rng.randf_range(1, 8), current_position.y + various_rng.randf_range(1, 8)), 0.05)
			grumble_tween.tween_property(self, "position", Vector2(current_position.x - various_rng.randf_range(1, 8), current_position.y - various_rng.randf_range(1, 8)), 0.05)
		
		grumble_tween.tween_property(self, "position", current_position, 0.05)
		
		
		tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.01)
		
	if not grumble_tween.is_valid():
		var current_position = self.position
		grumble_tween = get_tree().create_tween()
		scale_tween = get_tree().create_tween()
		var tween = get_tree().create_tween()
		
		tween.tween_property(self, "modulate", Color(0.75, 0.0, 0.0, 1.0), 0.01)
		tween.tween_interval(0.13)
		scale_tween.tween_property(self, "scale", self.scale * 0.75, 0.03)
		scale_tween.tween_callback(determine_object_scale.bind(0.03)).set_delay(0.08)
		
		var grumble_order = various_rng.randi_range(0, 1)
		
		if grumble_order == 0:
			grumble_tween.tween_property(self, "position", Vector2(current_position.x - various_rng.randf_range(1, 8), current_position.y - various_rng.randf_range(1, 8)), 0.05)
			grumble_tween.tween_property(self, "position", Vector2(current_position.x + various_rng.randf_range(1, 8), current_position.y + various_rng.randf_range(1, 8)), 0.05)
		
		if grumble_order == 1:
			grumble_tween.tween_property(self, "position", Vector2(current_position.x + various_rng.randf_range(1, 8), current_position.y + various_rng.randf_range(1, 8)), 0.05)
			grumble_tween.tween_property(self, "position", Vector2(current_position.x - various_rng.randf_range(1, 8), current_position.y - various_rng.randf_range(1, 8)), 0.05)
		
		grumble_tween.tween_property(self, "position", current_position, 0.05)
		tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.01)
