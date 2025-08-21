extends Node

const STONED = preload("res://COMBAT/STATUSES/StonedTile.gd")
const LOCKED = preload("res://COMBAT/STATUSES/LockedTile.gd")
const BURNING = preload("res://COMBAT/STATUSES/BurningTile.gd")
const PLAGUED = preload("res://COMBAT/STATUSES/PlaguedTile.gd")
const CRUMBLING = preload("res://COMBAT/STATUSES/CrumblingTile.gd")
const BURN_DEBUFF = preload("res://COMBAT/STATUSES/BurnDebuff.gd")
const POISON_DEBUFF = preload("res://COMBAT/STATUSES/PoisonDebuff.gd")
const BLEED_DEBUFF = preload("res://COMBAT/STATUSES/BleedDebuff.gd")
const IRRADIATED_DEBUFF = preload("res://COMBAT/STATUSES/IrradiatedDebuff.gd")
const MUDDLED_DEBUFF = preload("res://COMBAT/STATUSES/MuddledDebuff.gd")
const WARPED_DEBUFF = preload("res://COMBAT/STATUSES/WarpedDebuff.gd")

var StatusEffectList = {
	"STONED": STONED,
	"LOCKED": LOCKED,
	"BURNING": BURNING,
	"PLAGUED": PLAGUED,
	"CRUMBLING": CRUMBLING,
	"BURN_DEBUFF": BURN_DEBUFF,
	"POISON_DEBUFF": POISON_DEBUFF,
	"BLEED_DEBUFF": BLEED_DEBUFF,
	"IRRADIATED_DEBUFF": IRRADIATED_DEBUFF,
	"MUDDLED_DEBUFF": MUDDLED_DEBUFF,
	"WARPED_DEBUFF": WARPED_DEBUFF,
}
