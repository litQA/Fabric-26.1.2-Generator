<img width="1000" alt="fabric generator banner 26 1 2" src="https://github.com/user-attachments/assets/a210a188-8b5a-4e03-97b4-1754d6b0e59d" />

# Fabric 26.1.2 Generator

A Fabric generator for Minecraft 26.1.2. The project produces an installable MCreator generator
archive with Fabric Loader 0.20.1 and Fabric API 0.155.3 support.

## Requirements

- JDK 25 for building the plugin (generated projects target Java 25)
- Gradle 9.8.0, or the bundled wrapper
- MCreator with the plugin API range declared in `plugin.json`

## Build

```powershell
.\gradlew.bat build packagePlugin --no-daemon --console=plain
```

Output: `build/libs/generator-fabric-26.1.2.zip`.

The wrapper defaults to the public Gradle 9.8.0 distribution. Do not commit a local distribution URL; resolve any offline fallback dynamically from the workspace root.

A Gradle-free fallback is available for environments where the Gradle daemon cannot access the
workspace:

```powershell
pwsh -NoProfile -File .\tools\package.ps1
```

## Install

1. Close MCreator.
2. Copy the archive to the MCreator `plugins` directory.
3. Start MCreator and select the Fabric 26.1.2 generator for a new workspace.
4. Run **Generate code** once to copy the workspace base.

## Validation

```powershell
pwsh -NoProfile -File .\tools\validate.ps1
pwsh -NoProfile -File .\tools\check-archive.ps1
```

`validate.ps1` checks FreeMarker/YAML syntax, include resolution, template references and forbidden
API usage. `check-archive.ps1` reports the archive structure and SHA-256 digest.

## Layout

```
src/main/resources/
  plugin.json                  plugin metadata
  fabric-26.1.2/               entry generator
  fabric-26.1.2-base/          embedded datapack and NeoForge layers
  LICENSE                      CC BY-NC 4.0
tools/                         validation and packaging scripts
MIGRATION-REPORT.md            migration and verification record
FEATURE-ALIGNMENT-REPORT.md    new_features.txt coverage matrix
CHANGELOG.md                   release history
```

## Documentation

- `MIGRATION-REPORT.md` — migration, breaking changes, verification and known limitations
- `FEATURE-ALIGNMENT-REPORT.md` — `new_features.txt` coverage and compatibility fixes
- `CHANGELOG.md` — release history

## License

CC BY-NC 4.0. See `LICENSE` for details.

# MCreator - Minecraft Mod Maker

[![MCreator](https://mcreator.net/image/brand/mcreator300s.png)](https://mcreator.net/)

MCreator is an open-source software used to make Minecraft Java Edition mods, Minecraft Bedrock Edition Add-Ons, resource packs, and data packs using an intuitive easy-to-learn interface or with an integrated code editor. It is used worldwide by Minecraft players, aspiring mod developers, for education, online classes, and STEM workshops. 

NOT AN OFFICIAL MINECRAFT PRODUCT. NOT APPROVED BY OR ASSOCIATED WITH MOJANG OR MICROSOFT.
