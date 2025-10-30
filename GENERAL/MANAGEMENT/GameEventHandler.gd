extends Node

# Yes, Godot. I know that these signals are going unused. That's the entire point of this file.
@warning_ignore_start("unused_signal")

#region Combat Signals
## Updates the state of bagged tiles.
signal update_bag_tiles()
## Updates the state of buffered tiles.
signal update_buffered_tiles()
## Toggles the state of the Tile Bag.
signal disable_tile_bag(state)

## Emitted when a word is found and can be played by the player.
signal word_found					(word: String, sender: GameEntity, recipient: GameEntity)

## Emitted when a word is scored. A word with Repeating emits this multiple times.
signal word_scored					(word: String, sender: GameEntity, recipient: GameEntity)
## Emitted when a [GridTile] is scored during combat.
signal tile_scored					(which: GridTile, count: int)
#endregion

#region Shop Signals
## Emitted when the player attempts to buy something.
signal purchase_attempt				(which: Object, gold_value: int)
#endregion

#region Show/Hide tooltips
## Emitted when a [GridTile] is hovered.
signal tile_tooltip_requested		(which: GridTile)
## Emitted when a [MiniGridTile] is hovered.
signal tile_mini_tooltip_requested	(which: MiniGridTile)
## Emitted when a [GridTile] or [MiniGridTile] is unhovered, or when a [NotchObject] is hovered.
signal tile_tooltip_hide_requested	(force_hide: bool)
## Emitted when a [NotchObject] is hovered.
signal notch_tooltip_requested		(which: NotchObject)
## Emitted when a [NotchObject] is unhovered.
signal notch_tooltip_hide_requested	(force_hide: bool)
#endregion

#region Tile Signals
## Enum for actions performed on a [GridTile]. Play is a left click, View is a right click.
enum GridTileAction 				{PLAY, VIEW}
## Emitted when a [GridTile] is hovered or unhovered.
signal tile_hovered					(which: GridTile, is_hovering: bool)
## Emitted when a [MiniGridTile] is hovered or unhovered.
signal mini_tile_hovered			(which: MiniGridTile, is_hovering: bool)
## Emitted when a [GridTile] or [MiniGridTile] is clicked.
signal tile_clicked					(which: GridTile, action: GridTileAction)
## Emitted when a [GridTile]'s tooltip needs to be updated.
signal update_tile_tooltip			(which: GridTile)
#endregion

#region Notch Object Signals
## Emitted when a [NotchObject] is hovered.
signal notch_hovered				(which: NotchObject, is_hovering: bool)
## Emitted when a [NotchObject] is unclicked while not paired to a [GridTile].
signal send_back_home				(which: NotchObject)
#endregion

#region Relic Signals
## Enum for actions performed on a Relic. Fidget is a left click, View is a right click.
enum RelicAction 					{FIDGET, VIEW}
## Emitted when a [Relic] is hovered or unhovered.
signal relic_hovered				(which: Relic, is_hovering: bool)
## Emitted when a [Relic] is clicked.
signal relic_clicked				(which: Relic, action: RelicAction)
## Emitted when a [Relic] is activated.
signal relic_activated				(which: Relic)
## Emitted when a [Relic] is collected.
signal relic_collected				(which: Relic)
## Emitted as part of the process to add a [Relic] to the player's RelicCollection
signal add_relic					(relic_id: int, is_borrowed: bool, purchase_price: int)
## Emitted as part of the process of exchanging two [Relic]s at a Library.
signal exchange_relic				(relic_id: int, relic_index: int, is_borrowed: bool, purchase_price: int)
## Emitted when a Relic needs to change states, such as just_exchanged or just_borrowed when leaving a Library.
signal update_relic_states()
#endregion

#region Notch Pack Signals
## Enum for actions performed on a [NotchPack]. Fidget is a left click, View is a right click.
enum NotchPackAction 				{FIDGET, VIEW}
## Emitted when a [NotchPack] is hovered or unhovered.
signal notch_pack_hovered			(which: NotchPack, is_hovering: bool)
## Emitted when a [NotchPack] is clicked.
signal notch_pack_clicked			(which: NotchPack, action: NotchPackAction)
#endregion

#region Tile Rewrite Signals
## Emitted when the Tile Modify screen needs to be instantiated, such as when buying a Blank Tile.
signal tile_modify_popup			(which: GridTile)
## Emitted when the Tile Modify screen finishes modifying a [GridTile].
signal rewrite_deck_tile			(which: GridTile)
#endregion

#region Status Effect signals
## Emitted when a [StatusEffect] is hovered or unhovered.
signal status_hovered				(which: StatusEffect, is_hovering: bool)
## Emitted to activate any Thorns effects a [GameEntity] may have.
signal thorns_activated				(thorns_owner: GameEntity, attacker: GameEntity)
## Emitted when the Purity buff is activated and nullifies a negative [StatusEffect] inflicted by a [GameEntity]
signal purity_activated				(purity_owner: GameEntity, inflictor: GameEntity)
#endregion

#region Game Entity Signals
# These two signals update tile graphics, one on tooltips and the other on the tile itself.
## Emitted when [GridTiles] in the player's Rack need to be changed in any way.
signal update_tile_graphics			(which: GameEntity, affected_tile_indices: Array)
## Emitted when [MiniGridTiles] in an [Enemy]'s attack list need to be changed in any way.
signal update_tile_tooltip_graphics	(which: GameEntity, affected_tile_indices: Array)

# These signals handle what happens when you click or hover an entity.
## Enum for actions performed on a [GameEntity]. Target is a left click, View is a right click.
enum GameEntityAction 				{TARGET, VIEW}
## Emitted when a [GameEntity] is hovered or unhovered.
signal entity_hovered				(which: GameEntity, is_hovering: bool)
## Emitted when a [GameEntity] is clicked.
signal entity_clicked				(which: GameEntity, action: GameEntityAction)
## Emitted when a [GameEntity] is targeted.
signal entity_targeted				(which: GameEntity)

## Emitted when a [GameEntity] needs to process a word's effect on it.
signal process_word_effect          (word: String, score_value: int, sender: GameEntity, recipient: GameEntity)
## Emitted when a [GameEntity] needs to process some other kind of effect on it.
signal process_other_effect         (source: String, value: int, sender: GameEntity, recipient: GameEntity)
## Emitted when a [GameEntity] is affected by a word.
signal affected_by_word				(sender: GameEntity, recipient: GameEntity, word: String)
## Emitted when a [GameEntity] is affected by some other kind of effect.
signal affected_by_other            (sender: GameEntity, recipient: GameEntity, source: String)
## Emitted when a [GameEntity]'s weakness is activated by a word or an effect.
signal weakness_activated           (sender: GameEntity, recipient: GameEntity, reason: String)
## Emitted when a [GameEntity]'s resistance is activated by a word or an effect.
signal resistance_activated         (sender: GameEntity, recipient: GameEntity, reason: String)

## Emitted when a [GameEntity] starts its turn.
signal on_turn_start				(which: GameEntity, count: int)
## Emitted when a [GameEntity] ends its turn.
signal on_turn_end					(which: GameEntity, count: int)

## Emitted when a [GameEntity] takes damage.
signal take_damage					(amount: int, who: GameEntity, reason: String)
## Emitted when a [GameEntity] gains health.
signal health_gained				(amount: int, who: GameEntity, reason: String)
## Emitted when a [GameEntity] loses health.
signal health_lost					(amount: int, who: GameEntity, reason: String)
## Emitted when a [GameEntity] gains max health.
signal max_health_gained            (amount: int, who: GameEntity, reason: String)
## Emitted when a [GameEntity] loses max health.
signal max_health_lost              (amount: int, who: GameEntity, reason: String)

## Emitted when a [GameEntity] dies.
signal entity_has_died				(who: GameEntity, reason: String)

## Emitted when a [GameEntity] gains block.
signal block_gained					(amount: int, who: GameEntity, reason: String)
## Emitted when a [GameEntity] loses block.
signal block_lost					(amount: int, who: GameEntity, reason: String)
## Emitted when a [GameEntity] loses the last of their block.
signal block_broken					(who: GameEntity, reason: String)

## Emitted when a [GameEntity] needs to gain a [StatusEffect]. the "type" variable should be a [String] or [int]
signal apply_status_to_entity		(type: Variant, amount: int, duration: int, sender: GameEntity, recipient: GameEntity, reason: String)
## Emitted when a [GameEntity] gains a [StatusEffect].
signal status_gained				(type: StatusEffect, who: GameEntity, reason: String)
## Emitted when a [GameEntity] loses a [StatusEffect].
signal status_lost					(type: StatusEffect, who: GameEntity, reason: String)
#endregion

#region Enemy Signals
## Emitted when an Enemy needs to perform an attack.
signal perform_attack(attack_to_perform: Array, attack_letter_tiles: Array, pivot_position: Vector2) ## TODO: Change this.
## Emitted when an Enemy needs to end their turn.
signal pass_turn()
## Emitted when an Enemy finishes an attack.
signal enemy_attack_finished()
#endregion

#region Map Signals
## Emitted when a Room is selected on the Map.
signal selected(room: Room)
#endregion

#region Scene Transition Signals
## Emitted when Combat begins.
signal combat_started
## Emitted when Combat ends with the player's victory.
signal combat_won
## Emitted when a Combat Room is exited.
signal combat_exited
## Emitted when a Shop Room is entered.
signal shop_entered
## Emitted when a Shop Room is exited.
signal shop_exited
## Emitted when a Reliquary Room is entered.
signal reliquary_entered
## Emitted when a Reliquary Room is exited.
signal reliquary_exited
## Emitted when a Rest Room is entered.
signal rest_entered
## Emitted when a Rest Site Room is exited.
signal rest_exited
## Emitted when a Random Event Room is entered.
signal random_event_entered
## Emitted when a Random Event Room is exited.
signal random_event_exited
## Emitted when a Boss Room is entered.
signal boss_entered
## Emitted when a Boss Room is exited.
signal boss_exited
## Emitted when a Room is selected on the Map.
signal map_exited
## Emitted when all of the rewards in a Room are depleted.
signal reward_depleted
#endregion

#region Player Related Signals
## Emitted when the player gains or loses gold.
signal gold_changed(amount: int)
## Emitted when the player loses.
signal player_death
## Emitted when the Specialty Rewards screen needs to pop up, such as when purchasing a NotchPack.
signal specialty_rewards_popup(reward_notch_count: int, reward_notch_uncommons: int, reward_notch_rares: int, reward_notch_specified: Array, allow_tiles: bool, draw_size: int, refresh: bool, use_shop_rng: bool)
#endregion

#region Sound Bus Signals
## Emitted when an Entity needs to have a sound played.
signal play_entity_sound(sound_type: String, flavor_tag: String)
## Emitted when a GridTile needs to have the interaction sound played.
signal play_tile_sound(which: GridTile)
## Emitted when a GridTile needs the scoring sound played.
signal play_tile_scoring_sound(count: int)
## Emitted when a MiniGridTile needs to have a sound played.
signal play_mini_tile_sound(which: MiniGridTile)
## Emitted when a GridTile needs to have the sound for a Notch played.
signal play_tile_notch_sound(which: LetterTile.NotchTypes)
## Emitted when a GridTile needs to have a specific sound played.
signal play_misc_tile_sound(which: String)
