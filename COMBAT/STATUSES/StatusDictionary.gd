extends Node

var StatusEffectList = {
	"STONED": preload("res://COMBAT/STATUSES/StonedTile.gd"),
	"LOCKED": preload("res://COMBAT/STATUSES/LockedTile.gd"),
	"BURNING": preload("res://COMBAT/STATUSES/BurningTile.gd"),
	"PLAGUED": preload("res://COMBAT/STATUSES/PlaguedTile.gd"),
	"CRUMBLING": preload("res://COMBAT/STATUSES/CrumblingTile.gd"),
	"BURN_DEBUFF": preload("res://COMBAT/STATUSES/BurnDebuff.gd"),
	"POISON_DEBUFF": preload("res://COMBAT/STATUSES/PoisonDebuff.gd"),
	"BLEED_DEBUFF": preload("res://COMBAT/STATUSES/BleedDebuff.gd"),
	"IRRADIATED_DEBUFF": preload("res://COMBAT/STATUSES/IrradiatedDebuff.gd"),
}

const STONED = preload("res://COMBAT/STATUSES/StonedTile.gd")
const LOCKED = preload("res://COMBAT/STATUSES/LockedTile.gd")
const BURNING = preload("res://COMBAT/STATUSES/BurningTile.gd")
const PLAGUED = preload("res://COMBAT/STATUSES/PlaguedTile.gd")
const CRUMBLING = preload("res://COMBAT/STATUSES/CrumblingTile.gd")
const BURN_DEBUFF = preload("res://COMBAT/STATUSES/BurnDebuff.gd")
const POISON_DEBUFF = preload("res://COMBAT/STATUSES/PoisonDebuff.gd")
const BLEED_DEBUFF = preload("res://COMBAT/STATUSES/BleedDebuff.gd")
const IRRADIATED_DEBUFF = preload("res://COMBAT/STATUSES/IrradiatedDebuff.gd")
