# Fabric 26.1.2 Generator Migration Report

## 1. Baseline and target

| Item | Value |
|---|---|
| Baseline generator | Fabric Generator 26.1.2, upstream `2026.2-2.8.1` |
| Baseline MCreator | 2026.2 |
| Target MCreator | EAP 2026.3.44621 (`202600344621`) |
| Target Minecraft | 26.1.2 |
| Generator ID | `generator-fabric-26.1.2` |
| Plugin version | `2026.3-1.0.0-beta` |
| Fabric Loader | 0.20.1 |
| Fabric API | 0.155.3 |
| Java | 25 |
| Author | LitQA |
| License file | CC BY-NC 4.0, as required by the delivery specification; upstream GPL headers are retained in copied templates |

The port keeps the upstream Fabric 26.1.2 element model and its Minecraft 26.1.2 API calls. It applies the MCreator 2026.3.44621 generator semantics and adds the missing 2026.3 features listed in `new_features.txt`.

### 1.1 Reference comparison

| Reference | Role in this port | Adopted | Deliberately not adopted |
|---|---|---|---|
| `Fabric-Generator-MCreator-26.1.2-2026.3-2.8.1` | Baseline element model, templates, procedures, triggers and Minecraft 26.1.2 API calls | Main generator source tree | Upstream MCreator 2026.2 loading assumptions |
| `Fabric-Generator-MCreator-26.3-2026.3-2.9-beta` | Feature-complete Fabric 26.3 implementation for features and templates | New feature templates, Tab hide-title, armor unbreakable, synced-data branches, new procedure blocks | MC 26.3 rendering API changes (`SubmitNodeCollector`, `GuiGraphicsExtractor`, render-state refactors), 26.3 sign model paths, brewing recipe data changes |
| EAP built-in `fabric-26.3` 2.10 | Third-snapshot migration reference and real EAP packaging reference | `base_types`, fragments, `types.<plural>` migration patterns, `defaultRequire` behaviour | MC 26.3-only API calls and element fields |
| `NeoForge-26.1.2-Generator-main` (EAP port) | Same-Minecraft reference for `base_types`, multipart block states, force redstone conduction, void dimension, synced data, loot modifiers and invulnerable-time field access | Datapack and NeoForge-derived base layers, multipart/block/entity templates, `types.base_*` registration pattern | NeoForge Java registries, `@Mod`, capabilities, loot modifiers (no Fabric equivalent) |
| `NeoForge-26.3` / `datapack-26.3.x` | Feature-reference implementation for new procedure blocks and data-driven features | `attack_with_procedure`, strong-power procedure, item piglin-currency reference, enchantment effect fragments | NeoForge-only loot modifier generation, MC 26.3-only API changes |
| EAP `mcreator-core` / `mcreator-localization` | Target core procedure definitions, shadow blocks, localisation and plugin loading test | Shadow-block support inherited from core; localization used only for the load probe | No core files are copied into the plugin |

The main structural finding is that the old Fabric 26.1.2 and Fabric 26.3 generator trees share most procedure, trigger and mapping files. The 2026.3 work is concentrated in element definitions, the `types` template variable, base types, fragments, registration conditions and a small number of feature templates. The 26.3 rendering and worldgen path changes were not copied because the target remains Minecraft 26.1.2.

## 2. Embedded generator architecture

```text
plugin/
  plugin.json
  LICENSE
  CHANGELOG.md
  MIGRATION-REPORT.md
  FEATURE-ALIGNMENT-REPORT.md
  build.gradle / settings.gradle / gradle.properties
  gradle/wrapper/
  tools/validate.ps1
  tools/validate/ValidateYaml.java
  tools/validate/ValidateFtl.java
  src/main/resources/
    fabric-26.1.2/
      generator.yaml
      *.definition.yaml
      templates/ procedures/ triggers/ aitasks/ cmdargs/ utils/ variables/ mappings/
      workspacebase/
    fabric-26.1.2-base/
      datapack/        # namespaced, no generator.yaml
      neoforge/        # namespaced, no generator.yaml
```

The two base directories are private resource layers. `fabric-26.1.2/generator.yaml` imports them by path:

```yaml
import:
  - fabric-26.1.2-base/datapack
  - fabric-26.1.2-base/neoforge:
    exclude:
      - procedures
      - triggers
```

Only the main generator has a `generator.yaml`. The namespaced paths prevent collisions with an externally installed datapack or NeoForge generator plugin that uses the global MCreator plugin classloader.

## 3. 2026.3 breaking-change handling

### 3.1 `types` variable and `base_types`

MCreator 2026.3.44621 builds the template `types` map from element plural names and `base_<plural>` base-type names. `types[...]` bracket lookups and the old `??` existence checks are no longer reliable because the map is pre-populated with empty lists.

Handling:

- Added `base_types` to fourteen element definitions: armor, attribute, block, dimension, feature, fluid, item, itemextension, livingentity, particle, plant, projectile, specialentity and tool.
- Replaced every legacy `types["..."]` lookup in `modbase/mod.java.ftl`, `modbase/mod_client.java.ftl` and `modbase/mixin.json.ftl`.
- Base-provided initializers use `types.base_blocks`, `types.base_items`, `types.base_entities`, `types.base_blockentities`, `types.base_features` and `types.base_dispensebehaviors`. This is intentionally stricter than the upstream 26.3 Fabric templates, which use element-only keys in several places and can miss items or block entities in element-only workspaces.
- Added `common.dispensebehaviors.yaml` so the `dispensebehavior` base type drives `DispenseBehaviors.load()`.

### 3.2 Generator fragments

- `modbase/mixin.json.ftl` merges `(fragments.mixin)![]` into the generated mixin list and uses `defaultRequire: 0`.
- `modbase/accesswidener.ftl` renders `fragments.accesstransformer` before the user-code block.
- `tab.definition.yaml` declares the `hideTitle` access transformer as an element fragment. This is the only new access transformer introduced by this port; existing conditional access transformer lines remain in `accesswidener.ftl` for parity with the upstream generator.
- All 24 `@Inject` annotations in the mixin templates were changed to `@Inject(require = 0, ...)`.

### 3.3 YAML merge and loading

- The embedded base paths are namespaced; the definition provider only matches `fabric-26.1.2/*.definition.yaml` and `fabric-26.1.2/common.*.yaml`, so base definitions are not merged into the Fabric generator.
- The base `mappings/attributes.yaml` was trimmed of `NeoForgeMod.SWIM_SPEED` and `NeoForgeMod.NAMETAG_DISTANCE` so the merged attribute list cannot emit NeoForge Java references.
- The main generator has no `net.neoforged`, `@Mod`, `@EventBusSubscriber`, `Capability`, `IItemHandler` or `IFluidHandler` references.

### 3.4 Workspace versions and Gradle wrapper

- `generator.yaml` uses `buildfileversion: 0.155.3` and `subversion: 6`.
- `workspacebase/build.gradle` uses `net.fabricmc:fabric-loader:0.20.1`.
- The workspace wrapper and the plugin wrapper use the local Gradle 9.8.0 distribution URL required by the delivery specification.

## 4. `new_features.txt` status summary

The full item-by-item matrix is in `FEATURE-ALIGNMENT-REPORT.md`.

| Status | Count |
|---|---|
| Done | 15 |
| Core-driven | 2 |
| Done with adaptation | 2 |
| Not applicable | 1 |

The two adapted items are the creative tab `hideTitle` option and the piglin-currency procedure block. Both use the generator fragments access-transformer path because Minecraft 26.1.2 and Fabric expose the required behavior only through non-public members. The only not-applicable item is the NeoForge global loot modifier feature. Fabric API 0.155.3 has no equivalent registry; `lootTableToModify` is excluded instead of generating NeoForge code.

### 4.1 Workspace-driven compatibility fixes

Four real workspaces with 100-500 elements each were used as acceptance fixtures. They exposed four compatibility gaps that were not visible in the `new_features.txt` matrix:

| Fixture | Symptom | Root cause | Fix |
|---|---|---|---|
| `test-better-melon` | `HavingUsedEnchantedMelonSliceProcedure` was missing, leaving `QaBetterMelonModProcedures` uncompilable | The core 2026.3 trigger `player_useitem_finish` had no Fabric trigger template | Added `ENTITY_FINISH_USING_ITEM`, a `completeUsingItem` mixin injection and `triggers/player_useitem_finish.java.ftl` |
| `test-croparium-full` | Empty expressions such as `||>=64`, `sn = ;`, `== CpLibModItems...` in generated procedures | NeoForge `block_inv_*` procedure blocks had no Fabric templates; the old Fabric generator only shipped a small subset | Added all 13 `block_inv_*` templates backed by vanilla `Container` helpers |
| `test-croparium-full` | Empty numeric expressions from `entity_nbt_num_get/set` | NeoForge `Entity#getPersistentData()` is not a Fabric API | Added `entity_nbt_*` templates and a generated `${JavaModName}EntityNbt` helper backed by a persistent Fabric attachment |
| `test-everrose` | Armor inventory icon rendered as a missing texture while the worn armor rendered correctly | The armor item definitions used the misspelled variable `sufix`; the item model template reads `suffix` | Corrected all four armor model suffixes to `suffix` |

The `test-croparium-lite` workspace compiled and launched before these fixes and remains the control fixture.


## 5. Verification record

### 5.1 Static validation

Command:

```powershell
pwsh plugin/tools/validate.ps1 -MCreatorRoot <workspace>/MCreatorEAP2026344621
```

Result:

```text
Checks: 40, failures: 0
YAML files: 172, errors: 0
FTL files: 2604, errors: 0
```

The validator checks generator imports, single `generator.yaml`, template references, literal include resolution, legacy `types[...]` usage, NeoForge Java pollution, `defaultRequire`, fragment use, `base_types`, void dimension, enchantment effect templates, the new procedure templates, the custom attack AI task, Fabric Loader/Fabric API versions and the Gradle wrapper URL.

### 5.2 Real MCreator plugin load

A headless probe used the actual MCreator EAP classes, the real `PluginLoader`, the MCreator version number `202600344621`, and the packaged plugin ZIP.

Result:

```text
PLUGIN generator-fabric-26.1.2 version=2026.3-1.0.0-beta loaded=true compatible=true weight=10
failed plugins=0
```

### 5.3 Generator configuration probe

A partial generator configuration probe loaded the plugin, the generator YAML, both namespaced imports, the data lists and the block definition. It then reached MCreator's headless Blockly/variable-type initialization path and stopped there. This is an incomplete GUI bootstrap, not a generator loading failure; the same probe is not a substitute for a real workspace test.

### 5.4 Gradle build attempt

Command:

```powershell
$env:JAVA_HOME = "<workspace>/MCreatorEAP2026344621/jdk"
$env:GRADLE_USER_HOME = "<workspace>/caches/gradle"
plugin/gradlew.bat --no-daemon --no-watch-fs build
```

Result: the Gradle wrapper downloaded and started Gradle 9.8.0, but the Gradle build JVM reported that the project directory does not exist or cannot be written:

```text
Configuring project with invalid directory
Configuring project ':' without an existing directory is not allowed.
The configured projectDirectory '...\plugin' does not exist, can't be written to or is not a directory.
```

The Windows permission diagnostic returned `NOT_THIS_CLASS`; `WRITE_DAC`, `WRITE_OWNER` and the workspace access rights are present, and no ACL change was applied. The failure is a sandbox/Gradle child-process filesystem visibility restriction. The full report remains under `caches/acl-recovery/`.

### 5.5 Manual package verification

Because the Gradle daemon cannot see the project directory in this sandbox, the same resource tree was packaged with PowerShell:

```text
plugin/build/libs/generator-fabric-26.1.2.zip
size: 1,240,206 bytes
sha256: D1D23DB69EB8CA4CB20066D1663CE2B3DABB34385E29F1C240BF754D8A06D754
top-level: plugin.json, LICENSE, help/, fabric-26.1.2/, fabric-26.1.2-base/
generator.yaml count: 1
embedded base generator.yaml count: 0
```

The manual ZIP is structurally correct and was the archive used by the real MCreator plugin-loader probe. The Gradle build remains the authoritative build entry point on the user machine.

### 5.6 Four-workspace re-test state

The four acceptance workspaces were generated with the previous plugin build. After the compatibility fixes above, they must be regenerated before the final verdict:

| Fixture | Previous result | Expected after regeneration |
|---|---|---|
| `test-better-melon` | Compile failed on missing `HavingUsedEnchantedMelonSliceProcedure` | Procedure class generated; `player_useitem_finish` trigger available |
| `test-croparium-full` | Compile failed with empty `block_inv_*` and `entity_nbt_*` expressions | `block_inv_*` and `entity_nbt_*` templates emit complete code |
| `test-croparium-lite` | Compiled and client started | Regression check; should remain unchanged |
| `test-everrose` | Compiled and client started; armor inventory icon missing | Per-piece armor item models resolve; icon should use the generated item texture |

The previously generated Java and resource files are not patched in place. Regeneration from MCreator is required so the new templates are applied.

### 5.7 Generated-code API fixture compile

A fixture containing the new block-inventory helpers, the entity NBT attachment helper, the finish-use event and the `Container`-based damage path was compiled with `javac` 25 against:

- the Loom interface-injected Minecraft 26.1.2 jar from the `test-everrose` workspace;
- Fabric Loader 0.20.1;
- the Fabric API 0.155.3 module jars;
- the exact Mojang library versions from the 26.1.2 version manifest (`datafixerupper 9.0.19`, `fastutil 8.5.18`, `brigadier 1.3.10`, `authlib 7.0.63`, and related jars).

Result: `exit=0`. This validates the Java API usage of the workspace-driven fixes independently of MCreator's template rendering. The fixture is a development diagnostic under `caches/tools/fixture/` and is not part of the plugin.

## 6. Known limitations

- **Global loot modifiers**: not applicable to Fabric; `lootTableToModify` is hidden.
- **Transformable blocks**: `strippingResult` is hidden because the 26.3 `transformable` base type, axe interaction and access transformer are not ported. This is not a regression against the old 26.1.2 generator.
- **OBJ models**: the inherited NeoForge JSON templates use the `neoforge:obj` model loader. Fabric has no built-in equivalent. Custom OBJ models require a user-side check or a dedicated Fabric OBJ loader adaptation.
- **Hide tab title**: implemented with an access transformer on `CreativeModeTab$Builder.showTitle`. The field is visible in the 26.1.2 NeoForge patch context, but the generated class tweaker must be checked during a real client launch.
- **Piglin currency**: `ItemStack.isPiglinCurrency()` is a NeoForge extension and is not available in Fabric. The procedure block uses the vanilla `PiglinAi.isBarterCurrency(ItemStack)` helper through an access transformer fragment. The `Item` element property `isPiglinCurrency` remains excluded as a NeoForge-only field. The generated class tweaker must be checked during a real client launch.
- **Invulnerable-time field**: `entity_invulnerabletime` and `entity_set_invulnerabletime` use direct `invulnerableTime` field access, matching the NeoForge 26.1.2 reference. If the 26.1.2 runtime exposes accessors instead, the templates need a one-line change.
- **Entity NBT**: entity NBT is stored in a persistent Fabric data attachment, not NeoForge `Entity#getPersistentData()`. The generated helper covers numeric, logic, text and item-stack get/set blocks.
- **Block inventory procedures**: the `block_inv_*` family uses vanilla `Container` block entities. NeoForge `IItemHandler`-only blocks are not covered.
- **Finish-use trigger**: the `completeUsingItem` mixin uses `require = 0`; if the target method changes, the trigger is skipped rather than crashing.
- **Level-based enchantment input naming**: the `divided` input is represented by the `level_based_value_fraction.json.ftl` template. Confirm that the 2026.3 blockly XML uses the `fraction` template key.
- **No in-game test**: workspace creation, code generation, generated Gradle build and client launch were not performed in this sandbox.
- **License context**: the plugin LICENSE is CC BY-NC 4.0 per the delivery specification, while copied upstream templates retain their GPL-3.0 headers. Legal review is required before redistribution.

## 7. Required user-side verification

1. Install `generator-fabric-26.1.2.zip` into the MCreator EAP 2026.3.44621 plugins folder.
2. Confirm the Fabric 26.1.2 generator appears in the generator list without plugin errors.
3. Create a minimal workspace with one block (with a block item), one item and one procedure; confirm setup succeeds.
4. Generate code and run the generated Gradle build. Record the Minecraft/Fabric API resolution result.
5. Launch the client and verify the block model, item model, creative tab (including `hideTitle` if selected), enchantment effects and the new procedure blocks.
6. For a block entity workspace, verify that `Blocks.load()` and `BlockEntities.load()` are both generated and that the block entity registers.
7. If a custom OBJ model or a global loot modifier is selected, expect the documented limitation rather than a successful build.
8. Regenerate `test-better-melon` and confirm `HavingUsedEnchantedMelonSliceProcedure` is generated and the build succeeds.
9. Regenerate `test-croparium-full` and confirm the `block_inv_*` and `entity_nbt_*` procedures compile without empty expressions.
10. Regenerate `test-everrose` and confirm the armor inventory icons use `assets/<modid>/textures/item/<piece>.png` instead of the missing-texture placeholder. Re-run `test-croparium-lite` as the regression control.
