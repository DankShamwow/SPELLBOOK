extends Node

var various_rng = RandomnessManager.various_rng

func _ready():
	GameEventHandler.play_entity_sound.connect(_play_entity_sound)
	GameEventHandler.play_tile_sound.connect(_play_tile_sound)
	GameEventHandler.play_tile_notch_sound.connect(_play_tile_notch_sound)
	GameEventHandler.play_tile_scoring_sound.connect(_play_tile_scoring_sound)
	GameEventHandler.play_misc_tile_sound.connect(_play_misc_tile_sound)
	
func _play_entity_sound(sound_type: String, _flavor_tag: String):
	if sound_type == "BlockHitLight":
		var random_sound = various_rng.randi_range(0, 1)
		if random_sound == 0:
			%BlockHitLight1.play()
		else:
			%BlockHitLight2.play()
			
	if sound_type == "BlockHitHeavy":
		%BlockHitHeavy.play()
		
	if sound_type == "HitSoundTemp":
		%HitSoundTemp.play()
	
	if sound_type == "BlockGainHeavy":
		%BlockGainHeavy.play()
	
	if sound_type == "BlockGainLight":
		%BlockGainLight.play()
		
	if sound_type == "DeathSound":
		if not %HitSoundTemp.is_playing():
			%HitSoundTemp.play()

func _play_tile_sound(_which: GridTile):
	%TileSoundAttempt3.pitch_scale = various_rng.randf_range(0.965, 1.035)
	%TileSoundAttempt3.play()

func _play_mini_tile_sound(_which: MiniGridTile):
	%TileSoundAttempt3.pitch_scale = various_rng.randf_range(0.965, 1.035)
	%TileSoundAttempt3.play()

func _play_tile_notch_sound(which: LetterTile.NotchTypes):
	var no_sound_list = [
		LetterTile.NotchTypes.EMPTY, LetterTile.NotchTypes.REPEATING,			## Neither of these need a sound.
		LetterTile.NotchTypes.INERT, LetterTile.NotchTypes.GILDED,				## Inert may get a sound later. Gilded is handled in the gold handler.
		LetterTile.NotchTypes.FLAMING, LetterTile.NotchTypes.REJUVENATING,		## Both are handled elsewhere.
		LetterTile.NotchTypes.REINFORCED, LetterTile.NotchTypes.EAGER,			## Reinforced is handled with the block sound, Eager needs no sound.
		LetterTile.NotchTypes.BALANCED, LetterTile.NotchTypes.LOCAL, 			## Neither of these need a sound.
		LetterTile.NotchTypes.DISTANT, LetterTile.NotchTypes.PRICKLY,			## Distant needs no sound, Prickly is handled elsewhere 
		LetterTile.NotchTypes.POTENT, LetterTile.NotchTypes.LEXICAL,			## Neither of these need a sound.
		LetterTile.NotchTypes.VAPORIZING]										## Oops, forgot one. This is handled elsewhere.
	
	if no_sound_list.has(which):
		return
	
	elif which == LetterTile.NotchTypes.ECHOING:
		if not %EchoingAttempt1.is_playing():
			%EchoingAttempt1.play()
	
	elif which == LetterTile.NotchTypes.WEIGHTED:
		if not %WeightedNotchAttempt4.is_playing():
			%WeightedNotchAttempt4.play()
	
	elif which == LetterTile.NotchTypes.PHANTOM:
		if not %PhantomAttempt1.is_playing():
			%PhantomAttempt1.play()
			
	elif which == LetterTile.NotchTypes.OVERLOADED:
		if not %OverloadedAttempt1.is_playing():
			%OverloadedAttempt1.play()

func _play_tile_scoring_sound(count: int):
	%ScoringSoundAttempt1.pitch_scale = 1 + (0.025 * count)
	%ScoringSoundAttempt1.play()

func _play_misc_tile_sound(which: String):
	if which == "DESTROY":
		%DestructionVaporizationAttempt1.play()
