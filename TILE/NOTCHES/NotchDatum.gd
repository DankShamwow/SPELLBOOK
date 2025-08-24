class_name Notch
extends Resource

enum NotchTypes {REPEATING, ECHOING, VAPORIZING, WEIGHTED, INERT, GILDED, PHANTOM, FLAMING, REJUVENATING, REINFORCED, EAGER, PATIENT, QUICK, OVERLOADED, BALANCED, LOCAL, DISTANT, PRICKLY, POTENT, LEXICAL}

@export var type: NotchTypes
@export var letter = ""

func new_notch(_type, _letter = "") -> Notch:
	type = _type
	letter = _letter
	return self
