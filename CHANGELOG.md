## 2026.3-1.0.0-beta

### New Content

- Fabric Generator 26.1.2 target is MCreator EAP 2026.3.44621, with Fabric Loader 0.20.1, Fabric API 0.155.3 and Java 25.
- Embedded datapack and NeoForge-derived base layers are distributed under `fabric-26.1.2-base/`, so the plugin loads without an external datapack or NeoForge generator plugin.
- Element definitions declare `base_types`; template conditions use the 2026.3 `types.<plural>` and `types.base_<plural>` model.
- Generator fragments feed custom mixin class names and access transformer lines into the generated `mixins.json` and class tweaker.
- Multipart block state support is available through the embedded block state template and the Fabric block shape union.
- Custom block redstone conduction override is generated from `forceRedstoneConductor`.
- Void dimension world generation is registered through the embedded datapack `dimension_void.json.ftl` template.
- Enchantment data supports the new damage, knockback and armor effectiveness components, ordered value modifiers and level-based numeric inputs.
- Synced entity data can be used directly as animation and model layer conditions.
- Armor durability 0 removes `DataComponents.MAX_DAMAGE`, producing unbreakable armor pieces.
- Creative tab title hiding is implemented with an access transformer fragment on Minecraft 26.1.2.
- New procedure blocks cover strong redstone emission, vector dot product, line of sight, invulnerable time, attack cooldown, forced player attack, entity movement, item repair, empty stacks, piglin currency and item damage-source checks.
- New AI task `attack_with_procedure` adds a custom melee attack goal driven by a procedure.
- The piglin-currency check uses the vanilla `PiglinAi.isBarterCurrency` helper through an access transformer fragment; the NeoForge-only item property remains excluded.
- Fabric-compatible block inventory procedure blocks use vanilla `Container` access for slot queries, insertion, extraction, removal and item damage.
- Entity NBT procedure blocks persist through a Fabric data attachment helper generated only when an `entity_nbt_*` block is used.
- The `player_useitem_finish` trigger is driven by a `LivingEntity.completeUsingItem` mixin and the new `ENTITY_FINISH_USING_ITEM` event.

### Changes

- `plugin.json` uses generator ID `generator-fabric-26.1.2`, weight 10, author LitQA and version `2026.3-1.0.0-beta`.
- Only the main generator keeps `generator.yaml`; both embedded base layers are namespaced and have no `generator.yaml`.
- `modbase/mixin.json.ftl` uses `defaultRequire: 0`; all generated `@Inject` annotations use `require = 0`.
- The workspace Gradle wrapper points to the local Gradle 9.8.0 distribution required by the delivery specification.
- The NeoForge base attribute mapping is trimmed of `NeoForgeMod` entries to avoid generating NeoForge Java references.

### Fixes

Fixed 5 bug(s).

- Generator base layers no longer depend on externally installed `datapack-26.1.x` or `neoforge-26.1.2` plugin paths.
- Item loading is driven by `types.base_items`, so block items, armor, tools and other item-providing elements are registered even when no standalone item element exists.
- Armor inventory icons resolve to the generated per-piece item models after correcting the `suffix` model variable.
- The finish-use trigger no longer leaves a missing procedure class in workspaces that use `player_useitem_finish`.
- Block inventory and entity NBT procedure blocks no longer emit empty expressions and invalid Java.

### Known Limitations

- Global loot modifiers are not available through Fabric API; `lootTableToModify` is excluded from the Fabric loot table element.
- Block stripping (`strippingResult`) and the 26.3 `transformable` base type are not ported and the field is excluded.
- The inherited NeoForge object-model templates use the `neoforge:obj` model loader; custom OBJ models on Fabric require an explicit user-side check.
- The `hideTitle` adaptation relies on an access transformer for `CreativeModeTab$Builder.showTitle`; it must be verified in a real client launch.
- The piglin-currency procedure relies on an access transformer for the vanilla `PiglinAi.isBarterCurrency` helper; the `Item` element property `isPiglinCurrency` remains a NeoForge-only field and is excluded.
- The `entity_invulnerabletime` templates use direct field access, matching the NeoForge 26.1.2 reference; a 26.1.2 accessor change would require a template adjustment.
- Entity NBT is stored in a Fabric data attachment rather than NeoForge `Entity#getPersistentData()`; block inventory procedures require the target block entity to implement vanilla `Container`.
- Full Gradle and in-game verification must be completed on the user machine; see `MIGRATION-REPORT.md`.
