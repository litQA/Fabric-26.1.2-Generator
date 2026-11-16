# Changelog

All notable changes to the Fabric 26.1.2 generator are recorded in this file.

## 2026.3-1.0.4.3-beta

### Changes

- Version raised to `2026.3-1.0.4.3-beta` and rebuilt.
- Validation references now use generic test-workspace labels only.

### Fixes

Fixed 2 bug(s).

- Removed private test-workspace names and private generated-class names from the changelog, migration report and feature report.
- Packaging now writes forward-slash ZIP entries, and the archive checker rejects backslash entries.

## 2026.3-1.0.3.1-beta

### New Content

- Source-tree audit in `tools/validate.ps1` rejects hardcoded local absolute paths and `file:///` drive URLs in the plugin source and workspace templates.

### Changes

- Plugin version migrated to the four-field format `2026.3-1.0.3.1-beta`; the build sequence starts at 1 under the new scheme.
- The plugin wrapper and all three embedded `workspacebase` wrappers default to `https://services.gradle.org/distributions/gradle-9.8.0-bin.zip`.
- Any local Gradle fallback is no longer committed to source; it must be resolved dynamically from the workspace root and the `reference_resources` archive.

### Fixes

Fixed 1 bug(s).

- The plugin wrapper and workspace templates no longer contain hardcoded local `file:///` distribution URLs.

### Known Limitations

- The Gradle wrapper defaults to the public distribution URL. An offline fallback is not automatic; it must be supplied dynamically from the workspace root when the public download fails.

## 2026.3-1.0.2-beta

### New Content

- Plugin-level `README.md` with the standard banner, build, install, validation and layout sections.
- A `packagePlugin` Gradle alias and a reproducible `tools/package.ps1` fallback.
- Custom Java armor head models normalize the Blockbench root translation through `prepareCustomHeadPart`.
- The equipment layer mixin now applies `ArmorModel.getArmorTexture`, so custom armor model textures are used instead of the equipment layer texture.

### Changes

- Version raised to `1.0.2-beta`.
- Custom armor model documentation added to the migration and feature reports.

### Fixes

Fixed 2 bug(s).

- Custom armor models no longer use the equipment layer texture for their model UVs.
- Custom armor helmet models no longer inherit the Blockbench entity/block Y offset in head space.

### Known Limitations

- `prepareCustomHeadPart` only normalizes translation; authored rotation and scale remain unchanged.
- Custom armor model appearance must be verified in a real client session.

## 2026.3-1.0.1-beta

### New Content

- `player_useitem_finish` trigger backed by `ENTITY_FINISH_USING_ITEM` and a `completeUsingItem` mixin.
- All 13 `block_inv_*` procedure blocks backed by vanilla `Container` access.
- Eight `entity_nbt_*` procedure blocks backed by a generated persistent Fabric attachment helper.

### Changes

- Armor item model generation uses the correct `suffix` variable for all four armor pieces.
- Workspace-driven compatibility fixes are recorded in the migration report.

### Fixes

Fixed 3 bug(s).

- The finish-use trigger no longer leaves a missing procedure class.
- Block inventory and entity NBT procedure blocks no longer emit empty expressions and invalid Java.
- Armor inventory icons resolve to the generated per-piece item models.

### Known Limitations

- Entity NBT is stored in a Fabric data attachment rather than NeoForge `Entity#getPersistentData()`.
- Block inventory procedures require the target block entity to implement vanilla `Container`.
- The finish-use trigger uses a `require = 0` mixin; a target method change would skip the event.

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

### Changes

- `plugin.json` uses generator ID `generator-fabric-26.1.2`, weight 10, author LitQA and version `2026.3-1.0.0-beta`.
- Only the main generator keeps `generator.yaml`; both embedded base layers are namespaced and have no `generator.yaml`.
- `modbase/mixin.json.ftl` uses `defaultRequire: 0`; all generated `@Inject` annotations use `require = 0`.
- The workspace Gradle wrapper points to the required Gradle 9.8.0 distribution.
- The NeoForge base attribute mapping is trimmed of `NeoForgeMod` entries to avoid generating NeoForge Java references.

### Fixes

Fixed 2 bug(s).

- Generator base layers no longer depend on externally installed `datapack-26.1.x` or `neoforge-26.1.2` plugin paths.
- Item loading is driven by `types.base_items`, so block items, armor, tools and other item-providing elements are registered even when no standalone item element exists.

### Known Limitations

- Global loot modifiers are not available through Fabric API; `lootTableToModify` is excluded from the Fabric loot table element.
- Block stripping (`strippingResult`) and the 26.3 `transformable` base type are not ported and the field is excluded.
- The inherited NeoForge object-model templates use the `neoforge:obj` model loader; custom OBJ models on Fabric require an explicit user-side check.
- The `hideTitle` adaptation relies on an access transformer for `CreativeModeTab$Builder.showTitle`; it must be verified in a real client launch.
- The piglin-currency procedure relies on an access transformer for the vanilla `PiglinAi.isBarterCurrency` helper; the `Item` element property `isPiglinCurrency` remains a NeoForge-only field and is excluded.
- The `entity_invulnerabletime` templates use direct field access, matching the NeoForge 26.1.2 reference; a 26.1.2 accessor change would require a template adjustment.
- The `divided` level-based enchantment input is represented by the `level_based_value_fraction.json.ftl` template.
- Full Gradle and in-game verification must be completed on the user machine; see `MIGRATION-REPORT.md`.
- The plugin LICENSE is CC BY-NC 4.0 per the delivery specification, while copied upstream templates retain their GPL-3.0 headers. Legal review is required before redistribution.
