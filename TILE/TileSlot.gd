extends Control
class_name TileSlot

@export var grid_tile_scene: PackedScene = preload("res://TILE/GridTile.tscn")

@export var tile: GridTile
@export var ghost_tile: GridTile = null

enum TileSlotAction {
	PLAY, VIEW,
}

signal slot_input(which: TileSlot, action: TileSlotAction)
signal slot_hovered(which: TileSlot, is_hovering: bool)

# What happens when you click on a slot?
func _on_texture_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			slot_input.emit(
				self, TileSlotAction.PLAY
			)
			print("LEFT CLICK INITIATED.")
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			slot_input.emit(
				self, TileSlotAction.VIEW
			)
			print("RIGHT CLICK INITIATED.")

func play_tile() -> GridTile:
	var temp_tile := self.tile
	if temp_tile:
		self.tile.fade()
	return temp_tile
	

func is_empty():
	return self.tile == null

# What happens when we hover a slot?
func _on_texture_button_mouse_entered():
	slot_hovered.emit(self, true)

func _on_texture_button_mouse_exited():
	slot_hovered.emit(self, false)
	
func update_slot():
	if tile:
		if not self.get_children().has(tile):
			add_child(tile)
	if ghost_tile:
		if not self.get_children().has(ghost_tile):
			add_child(ghost_tile)
