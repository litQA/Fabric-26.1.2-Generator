# Fabric 26.1.2 Generator: `new_features.txt` Alignment Report

Target environment: MCreator EAP 2026.3.44621 (`202600344621`), Minecraft 26.1.2, Fabric Loader 0.20.1, Fabric API 0.155.3, Java 25.

Status vocabulary:

- **Done**: implemented in this plugin and covered by a static check.
- **Core-driven**: the target MCreator core supplies the UI or data; the Fabric generator requires no additional template change.
- **Not applicable**: Fabric has no equivalent runtime API; the field is hidden or documented.
- **Pending runtime**: implemented, but the final confirmation requires a generated workspace build or an in-game test.

| # | new_features.txt item | Status | Reference implementation | Old Fabric 26.1.2 gap | Target location | Verification |
|---|---|---|---|---|---|---|
| 1 | Multipart block states | Done | `neoforge-26.1.2/templates/json/block_states.json.ftl`; EAP `fabric-26.3/templates/block/block.java.ftl` shape union | No `multipartModel` handling in the old block model or block shape logic | Embedded base `json/block_states.json.ftl`; `fabric-26.1.2/templates/block/block.java.ftl` | FTL parse, static feature check; workspace test pending |
| 2 | Synced data directly as animation conditions | Done | `neoforge-26.1.2/templates/livingentity/livingentity.java.ftl` and `livingentity_renderer.java.ftl` | Old template only accepted procedure conditions | `animation.syncedDataCondition` branch in both living entity templates | FTL parse; runtime pending |
| 3 | Shadow blocks in procedure blocks | Core-driven | `mcreator-core/procedures/*.json` `<shadow>` entries | No generator-side gap; procedure templates already render shadow defaults | Target MCreator core, no Fabric template change | Target core is the authoritative source |
| 4 | Force redstone conduction on custom blocks | Done | `neoforge-26.1.2/templates/block/block.java.ftl`; core `Block.forceRedstoneConductor` | Old template always used `isRedstoneConductor(... -> false)` | `fabric-26.1.2/templates/block/block.java.ftl` | FTL parse, static field check; runtime pending |
| 5 | Custom loot tables as loot modifiers | Not applicable | NeoForge `loottable.definition.yaml` + `loot_modifiers` template | Fabric API has no global loot modifier registry | `loottable.definition.yaml`: `field_exclusions: [lootTableToModify]` | Static exclusion check |
| 6 | Dimension world generation type `void` | Done | `datapack-26.1.x/templates/dimension/dimension_void.json.ftl` and `void_noise_router.json.ftl` | Old dimension definition had only overworld, nether and end entries | `fabric-26.1.2/dimension.definition.yaml`; embedded datapack templates | FTL parse, static template reference check |
| 7 | Enchantment effects: weapon damage/knockback, armor effectiveness | Done | `datapack-26.1.x/enchantmenteffects/ench_component_{damage,knockback,armor_effectiveness}.json.ftl` | Old Fabric package did not carry the effect fragments | Embedded datapack plus `fabric-26.1.2/enchantmenteffects/` | File presence, FTL parse |
| 8 | Enchantment value modifier: ordered value modifiers | Done | `datapack-26.1.x/enchantmenteffects/value_effect_all_of.json.ftl` and the add/multiply/set fragments | Old Fabric package did not carry the ordered modifier fragment | Embedded datapack plus `fabric-26.1.2/enchantmenteffects/` | File presence, FTL parse |
| 9 | Level-based enchantment inputs: linear, clamped, divided, squared, lookup | Done | `datapack-26.1.x/enchantmenteffects/level_based_value_{linear,clamped,fraction,squared,lookup}.json.ftl` | Old Fabric package did not carry the level-based fragments | Embedded datapack plus `fabric-26.1.2/enchantmenteffects/` | File presence, FTL parse; `divided` is represented by the `fraction` template name |
| 10 | Water and fall damage resetting modes in raytrace blocks | Core-driven | `mcreator-core/procedures/entity_lookpos*.json` with `WATER` and `FALLDAMAGE_RESETTING` | Generator templates already interpolate `ClipContext.Fluid` and `ClipContext.Block` values | Existing fabric procedure templates | Core-driven; MC 26.1.2 enum values assumed present |
| 11 | Strong power emission for a particular block face | Done | NeoForge/Fabric 26.3 `procedures/world_data_get_emitted_strong_redstone_power.java.ftl` | Template missing from old Fabric generator | `fabric-26.1.2/procedures/world_data_get_emitted_strong_redstone_power.java.ftl` | FTL parse |
| 12 | Vector procedure blocks: dot product and cross product | Done | `procedures/vector_dot.java.ftl`; core `vector_dual_ops` cross option | Dot template missing; cross already existed through the dual-op dropdown | Added `vector_dot.java.ftl`; cross remains core-driven | FTL parse |
| 13 | Entity blocks: line of sight, invulnerable time, attack cooldown, reset, forced attack | Done | `neoforge-26.1.2` field-access templates and NeoForge/Fabric 26.3 attack templates | Six templates missing from old Fabric generator | Added `entity_has_line_of_sight`, `entity_invulnerabletime`, `entity_set_invulnerabletime`, `entity_attackcooldown`, `entity_attackcooldown_reset`, `entity_forceplayerattack` | FTL parse; `invulnerableTime` field chosen from the 26.1.2 reference |
| 14 | Armor unbreakable when durability is 0 | Done | EAP `fabric-26.3/templates/armor/armor.java.ftl` | Old armor template always added `MAX_DAMAGE` | `fabric-26.1.2/templates/armor/armor.java.ftl` | FTL parse, static check; runtime pending |
| 15 | Synced data directly as entity layer conditions | Done | `neoforge-26.1.2/templates/livingentity/livingentity_renderer.java.ftl` | Old renderer only accepted procedure layer conditions | `layer.syncedDataCondition` branch and `needsEntityInState` handling | FTL parse |
| 16 | Attribute modifiers enchantment component | Done | `datapack-26.1.x/enchantmenteffects/ench_component_attributes.json.ftl` | Old Fabric package did not carry the component fragment | Embedded datapack plus `fabric-26.1.2/enchantmenteffects/` | File presence, FTL parse |
| 17 | Creative tab parameter: hide tab title | Done with adaptation | EAP Fabric/NeoForge 26.3 `.hideTitle()` | Minecraft 26.1.2 exposes no public `hideTitle()` builder method in the reference context | `tab.definition.yaml` AT fragment for `CreativeModeTab$Builder.showTitle`; `elementinits/tabs.java.ftl` | Static fragment check; runtime AT verification pending |
| 18 | Entity AI task: custom attack with procedure | Done | NeoForge 26.3 `aitasks/attack_with_procedure.java.ftl` and core task JSON | Template missing from old Fabric generator | `fabric-26.1.2/aitasks/attack_with_procedure.java.ftl` | FTL parse |
| 19 | Entity procedure block: is entity moving | Done | EAP Fabric 26.3 `procedures/entity_is_moving.java.ftl` | Template missing from old Fabric generator | `fabric-26.1.2/procedures/entity_is_moving.java.ftl` | FTL parse |
| 20 | Item procedure blocks: can repair, is empty, piglin currency, can damage source hurt item | Done with adaptation | EAP Fabric 26.3 for repair/empty/hurt; vanilla `PiglinAi.isBarterCurrency` for piglin currency | Four templates missing; `ItemStack.isPiglinCurrency()` is a NeoForge extension, not a Fabric API | Four procedure templates; `item_is_piglin_currency.java.ftl` uses the vanilla helper; `procedure.definition.yaml` contributes the AT fragment; the NeoForge-only item property remains excluded | FTL parse, static fragment check; runtime AT verification pending |

## Porting classification

- **Directly portable (15 items)**: multipart block states, synced-data animation conditions, force redstone conduction, void dimension, enchantment effects, ordered value modifiers, level-based enchantment inputs, strong-power procedure, vector dot/cross, entity line-of-sight/cooldown/invulnerable-time/forced-attack procedures, armor unbreakable, synced-data layer conditions, attribute-modifier enchantment component, custom attack AI task, entity-is-moving procedure.
- **Core-driven, no generator bridge (2 items)**: shadow blocks in procedure blocks; water/fall-damage raytrace modes.
- **Needs an adaptation layer (2 items)**: creative tab hide title and piglin-currency procedure. Both use the generator fragments access-transformer path instead of hardcoded output.
- **Not applicable to Fabric (1 item)**: global loot modifiers, because Fabric API has no global loot modifier registry.
- **Requires user-side confirmation**: the two access-transformer adaptations, the direct `invulnerableTime` field access, the `neoforge:obj` custom OBJ model path, and the complete generated-workspace/client build.

## Additional compatibility decisions

- `lootTableToModify` is excluded because Fabric API 0.155.3 does not provide the NeoForge global loot modifier registry.
- `strippingResult` is excluded because the `transformable` base type and its axe interaction are not part of this port and are not in `new_features.txt`.
- The inherited NeoForge object-model JSON templates use `neoforge:obj`; this is retained for upstream parity and documented as a limitation for custom OBJ models.
- `types.base_items`, `types.base_blocks`, `types.base_entities`, `types.base_blockentities`, `types.base_features` and `types.base_dispensebehaviors` are used for registration calls so element-only workspaces do not miss generated initializers.
- Generator fragments are used for the new `hideTitle` access transformer and for any future element-level mixin or access transformer additions.

## Compatibility fixes from the four acceptance workspaces

These items are outside `new_features.txt` but were required by real 100-500 element workspaces:

| Fixture symptom | Fix | Status |
|---|---|---|
| `player_useitem_finish` procedure class missing | Added the `ENTITY_FINISH_USING_ITEM` event, `completeUsingItem` mixin and trigger template | Implemented; regeneration pending |
| Empty `block_inv_*` expressions | Added all 13 block inventory templates using vanilla `Container` helpers | Implemented; regeneration pending |
| Empty `entity_nbt_*` expressions | Added eight entity NBT templates and the `${JavaModName}EntityNbt` persistent attachment helper | Implemented; regeneration pending |
| Armor inventory icon missing texture | Corrected the armor model `suffix` variable from `sufix` | Implemented; regeneration pending |
| Custom Java armor model texture and skeleton abnormal | Applied `ArmorModel.getArmorTexture` in the equipment mixin and normalized the helmet root translation with `prepareCustomHeadPart` | Implemented; in-game visual check pending |

The block inventory family covers slot count, slot stack limit, slot item, slot amount, insert, extract, set, clear and remove operations. The entity NBT family uses a persistent Fabric attachment and does not emit NeoForge `getPersistentData()`.

