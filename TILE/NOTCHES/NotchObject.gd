extends Control
class_name NotchObject

@onready var notch: Notch

var NotchDescriptions = {
"REPEATING": 	"This Tile triggers an additional time.",
"ECHOING":		"This Tile returns to the rack once when played.",
"VAPORIZING":	"This Tile is permanently removed from your Bag when played.",
"WEIGHTED":		"This Tile skips the Tile Buffer after being played.",
"INERT":		"This Tile becomes immune to negative Statuses.",
"GILDED":		"+5 gold at the end of combat if this Tile is Racked.",
"PHANTOM":		"Creates two Temporary copies of this Tile when scored.",
"FLAMING":		"When targeting an enemy, this Tile inflicts 3 Burn.",
"REJUVENATING":	"Once per combat, heal for 3 when scoring this Tile.",
"REINFORCED":	"When this Tile is scored, you gain 5 block.",
"EAGER":		"This tile is drawn at the beginning of combat.",
"PATIENT":		"This Tile gains +3 points per turn while held in your Rack. Resets when drawn.",
"QUICK":		"This Tile gains +10 points when scored the turn it is drawn.",
"OVERLOADED":	"When this Tile is scored, lose 1 Energy and double your current Word Score.",
"BALANCED":		"This Tile gains +3 points for each pair of Tiles that come before and after it in the played word.",
"LOCAL":		"This Tile gains +1 point for each Tile that comes after it in the played word.",
"DISTANT":		"This Tile gains +1 point for each Tile that comes before it in the played word.",
"PRICKLY":		"When targeting an enemy, this Tile inflicts Bleed equal to its Letter Score.",
"POTENT":		"This tile gains +3 points."
						}

const UPPER_CORNER = Vector2(208, 88)
const LOWER_CORNER = Vector2(400, 120)

var has_mouse := false
var dragging := false
var offset = Vector2(16, 16)
var paired_tile: GridTile

var home_pose = Vector2(0, 0)

var folded := true

var original_z = self.z_index

var tween: Tween
var tween2: Tween

var has_affected_notch1 := false
var has_affected_notch2 := false
var has_affected_notch3 := false

signal send_back_home(which: NotchObject)
signal has_paired()
signal notch_hovered(which: NotchObject, is_hovering: bool)
signal update_tooltip(which: GridTile)

func _ready():
	print(notch.type)
	%LeftWing.set_frame_coords(Vector2i(notch.type, 0))
	%RightWing.set_frame_coords(Vector2i(notch.type, 1))
	%Nub.set_frame_coords(Vector2i(notch.type, 2))
	%Marker.set_frame_coords(Vector2i(notch.type, 3))
	add_to_group("Notches to Add")
	NotchDescriptions["LEXICAL"] = str('This Tile gains an extra Letter. This Notch grants the letter "' + str(notch.letter.to_upper()) + '"')

func _on_texture_button_down():
	if tween:
		tween.kill()
	
	dragging = true
	tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "rotation_degrees", 0.0, 0.15)
	
	if has_affected_notch1 == true:
		$AnimationPlayer.play("fold")
		folded = true
		has_affected_notch1 = false
		paired_tile.tile.notch1 = LetterTile.NotchTypes.EMPTY
		paired_tile.tile.bonus_letter1 = ""
		paired_tile.update_notch_graphics(1, true)
		
		paired_tile = null
		
	elif has_affected_notch2 == true:
		$AnimationPlayer.play("fold")
		folded = true
		has_affected_notch2 = false
		paired_tile.tile.notch2 = LetterTile.NotchTypes.EMPTY
		paired_tile.tile.bonus_letter2 = ""
		paired_tile.update_notch_graphics(2, true)
		
		paired_tile = null
		
	elif has_affected_notch3 == true:
		$AnimationPlayer.play("fold")
		folded = true
		has_affected_notch3 = false
		paired_tile.tile.notch3 = LetterTile.NotchTypes.EMPTY
		paired_tile.tile.bonus_letter3 = ""
		paired_tile.update_notch_graphics(3, true)
		
		paired_tile = null
		
	else:
		get_tree().call_group("Notches to Add", "_resnap_to_paired_tile")

func _on_texture_button_up():
	dragging = false
	if %Area2D.has_overlapping_areas():
		var overlaps = %Area2D.get_overlapping_areas()
		for i in overlaps.size():
			print(overlaps[i].get_parent())
			if overlaps[i].get_parent() is GridTile:
				print("Pairing found!")
				paired_tile = overlaps[i].get_parent()
				_snap_to_paired_tile(paired_tile)
				update_tooltip.emit(paired_tile)
				has_paired.emit()
				break
	
	get_tree().call_group("Notches to Add", "_resnap_to_paired_tile")
	if has_affected_notch1 == false and has_affected_notch2 == false and has_affected_notch3 == false:
		var spin_when_dropped = randf_range(-22.5, 22.5)
		tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_SPRING)
		tween.tween_property(self, "rotation_degrees", spin_when_dropped, 0.05)
		_send_back_home()

func _resnap_to_paired_tile():
	# NOTE: I'm not sure I need to have a safeguard against someone clicking the notch while it's doing this stuff.
	# I also have no clue what kind of effect that would have.
	# If they can manage to do it and wring an extra notch out of it, they deserve to keep it.
	if paired_tile:
		print("Resnapping!")
		var paired_tile_pose = paired_tile.position
		if paired_tile:
			if paired_tile.tile.notch1 == LetterTile.NotchTypes.EMPTY and has_affected_notch2 == true:
				tween = get_tree().create_tween()
				tween2 = get_tree().create_tween()
				tween.set_trans(Tween.TRANS_SPRING)
				tween2.set_trans(Tween.TRANS_SPRING)
				tween.tween_property(self, "rotation_degrees", 180.0, 0.15)
				tween2.tween_property(self, "position", paired_tile_pose, 0.15)
				paired_tile.tile.notch2 = LetterTile.NotchTypes.EMPTY
				paired_tile.tile.bonus_letter2 = ""
				paired_tile.tile.notch1 = LetterTile.NotchTypes[Notch.NotchTypes.keys()[notch.type]]
				paired_tile.tile.bonus_letter1 = notch.letter
				paired_tile.update_notch_graphics(2, true)
				paired_tile.update_notch_graphics(1, true)
				print(str(paired_tile.tile.NotchTypes.keys()[paired_tile.tile.notch1]).to_pascal_case())
				
				has_affected_notch1 = true
				has_affected_notch2 = false
				
		await get_tree().create_timer(0.15).timeout
		
		if paired_tile:
			if paired_tile.tile.notch2 == LetterTile.NotchTypes.EMPTY and has_affected_notch3 == true:
				tween = get_tree().create_tween()
				tween2 = get_tree().create_tween()
				tween.set_trans(Tween.TRANS_SPRING)
				tween2.set_trans(Tween.TRANS_SPRING)
				tween.tween_property(self, "rotation_degrees", -90.0, 0.15)
				tween2.tween_property(self, "position", paired_tile_pose + Vector2(-16, -16), 0.15)
				paired_tile.tile.notch3 = LetterTile.NotchTypes.EMPTY
				paired_tile.tile.bonus_letter3 = ""
				paired_tile.tile.notch2 = LetterTile.NotchTypes[Notch.NotchTypes.keys()[notch.type]]
				paired_tile.tile.bonus_letter2 = notch.letter
				paired_tile.update_notch_graphics(3, true)
				paired_tile.update_notch_graphics(2, true)
				print(str(paired_tile.tile.NotchTypes.keys()[paired_tile.tile.notch2]).to_pascal_case())
				
				has_affected_notch2 = true
				has_affected_notch3 = false
		
		await get_tree().create_timer(0.15).timeout

	else:
		return

@warning_ignore("shadowed_variable")
func _snap_to_paired_tile(paired_tile: GridTile):
	var paired_tile_pose = paired_tile.position 
	if paired_tile.tile.notch1 == LetterTile.NotchTypes.EMPTY:
		tween = get_tree().create_tween()
		tween2 = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_SPRING)
		tween2.set_trans(Tween.TRANS_SPRING)
		tween.tween_property(self, "rotation_degrees", 180.0, 0.15)
		tween2.tween_property(self, "position", paired_tile_pose, 0.15)
		paired_tile.tile.notch1 = LetterTile.NotchTypes[Notch.NotchTypes.keys()[notch.type]]
		print(Notch.NotchTypes.keys()[notch.type])
		print(LetterTile.NotchTypes[Notch.NotchTypes.keys()[notch.type]])
		print(notch.type)
		paired_tile.tile.bonus_letter1 = notch.letter
		paired_tile.update_notch_graphics(1, true)
		print(str(paired_tile.tile.NotchTypes.keys()[paired_tile.tile.notch1]).to_pascal_case())
		
		has_affected_notch1 = true
		if folded:
			$AnimationPlayer.play("unfold")
			folded = false
			notch_hovered.emit(self, true)
	
	elif paired_tile.tile.notch2 == LetterTile.NotchTypes.EMPTY:
		tween = get_tree().create_tween()
		tween2 = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_SPRING)
		tween2.set_trans(Tween.TRANS_SPRING)
		tween.tween_property(self, "rotation_degrees", -90.0, 0.15)
		tween2.tween_property(self, "position", paired_tile_pose + Vector2(-16, -16), 0.15)
		paired_tile.tile.notch2 = LetterTile.NotchTypes[Notch.NotchTypes.keys()[notch.type]]
		paired_tile.tile.bonus_letter2 = notch.letter
		paired_tile.update_notch_graphics(2, true)
		print(str(paired_tile.tile.NotchTypes.keys()[paired_tile.tile.notch2]).to_pascal_case())
		
		has_affected_notch2 = true
		if folded:
			$AnimationPlayer.play("unfold")
			folded = false
			notch_hovered.emit(self, true)
		
	elif paired_tile.tile.notch3 == LetterTile.NotchTypes.EMPTY:
		tween = get_tree().create_tween()
		tween2 = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_SPRING)
		tween2.set_ease(Tween.EASE_IN_OUT)
		tween2.set_trans(Tween.TRANS_SPRING)
		tween.tween_property(self, "rotation_degrees", 90.0, 0.15)
		tween2.tween_property(self, "position", paired_tile_pose + Vector2(16, -16), 0.15)
		paired_tile.tile.notch3 = LetterTile.NotchTypes[Notch.NotchTypes.keys()[notch.type]]
		paired_tile.tile.bonus_letter3 = notch.letter
		paired_tile.update_notch_graphics(3, true)
		print(str(paired_tile.tile.NotchTypes.keys()[paired_tile.tile.notch3]).to_pascal_case())
		has_affected_notch3 = true
		if folded:
			$AnimationPlayer.play("unfold")
			folded = false
			notch_hovered.emit(self, true)

	else:
		return

@warning_ignore("unused_parameter")
func _process(delta):
	if dragging:
		global_position = get_global_mouse_position() - offset

func _on_texture_button_mouse_entered():
	has_mouse = true
	print(has_mouse)
	original_z = self.z_index
	self.scale = self.scale * 1.1
	self.z_index = 128
	notch_hovered.emit(self, true)
	
func _on_texture_button_mouse_exited():
	has_mouse = false
	print(has_mouse)
	self.scale = self.scale / 1.1
	self.z_index = original_z
	notch_hovered.emit(self, false)

func _force_home():
	if has_affected_notch1 == true:
		$AnimationPlayer.play("fold")
		folded = true
		has_affected_notch1 = false
		paired_tile.tile.notch1 = LetterTile.NotchTypes.EMPTY
		paired_tile.tile.bonus_letter1 = ""
		paired_tile.update_notch_graphics(1, true)
		
		paired_tile = null
		
	elif has_affected_notch2 == true:
		$AnimationPlayer.play("fold")
		folded = true
		has_affected_notch2 = false
		paired_tile.tile.notch2 = LetterTile.NotchTypes.EMPTY
		paired_tile.tile.bonus_letter2 = ""
		paired_tile.update_notch_graphics(2, true)
		
		paired_tile = null
		
	elif has_affected_notch3 == true:
		$AnimationPlayer.play("fold")
		folded = true
		has_affected_notch3 = false
		paired_tile.tile.notch3 = LetterTile.NotchTypes.EMPTY
		paired_tile.tile.bonus_letter3 = ""
		paired_tile.update_notch_graphics(3, true)
		
		paired_tile = null
		
	tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "rotation_degrees", 0.0, 0.15)
	
	_send_back_home()

func _send_back_home():
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "global_position", home_pose, 1)
	send_back_home.emit(self)
	
func _query_paired_tile():
	return paired_tile

func play_pairing_anim():
	var paired_tile_pose = paired_tile.position 
	%AnimationPlayer.play("pairing")
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	
	if has_affected_notch1 == true:
		tween.tween_property(self, "position", paired_tile_pose + Vector2(0, 8), 0.1)
		tween.tween_interval(0.2)
		tween.tween_property(self, "position", paired_tile_pose + Vector2(0, -16), 0.1)
		await get_tree().create_timer(0.41).timeout
		paired_tile.update_notch_graphics(1, false)
		return true
		
	elif has_affected_notch2 == true:
		tween.tween_property(self, "position", paired_tile_pose + Vector2(-24, -16), 0.1)
		tween.tween_interval(0.2)
		tween.tween_property(self, "position", paired_tile_pose + Vector2(0, -16), 0.1)
		await get_tree().create_timer(0.41).timeout
		paired_tile.update_notch_graphics(2, false)
		return true
		
	elif has_affected_notch3 == true:
		tween.tween_property(self, "position", paired_tile_pose + Vector2(24, -16), 0.1)
		tween.tween_interval(0.2)
		tween.tween_property(self, "position", paired_tile_pose + Vector2(0, -16), 0.1)
		await get_tree().create_timer(0.41).timeout
		paired_tile.update_notch_graphics(3, false)
		return true
