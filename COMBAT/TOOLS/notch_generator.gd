extends Control
class_name NotchGenerator

const NOTCH_OBJECT_SCENE = preload("res://TILE/NOTCHES/EditorNotchObject.tscn")

@export var type: Notch.NotchTypes

func _ready():
	_spawn_new_child_notch()

func _spawn_new_child_notch():
	var notch_datum = Notch.new().new_notch(type)
	var notch_child = NOTCH_OBJECT_SCENE.instantiate()
	%NotchesParent.add_child(notch_child)
	notch_child.scale = Vector2(0.5, 0.5)
	notch_child.notch = notch_datum
	notch_child.has_paired.connect(self._spawn_new_child_notch)
	notch_child.send_back_home.connect(self._notch_removed_cleanup)
	notch_child.position = self.position
	notch_child.setup_notch()

func _notch_removed_cleanup(which: EditorNotchObject):
	which.queue_free()
	_spawn_new_child_notch()
	
