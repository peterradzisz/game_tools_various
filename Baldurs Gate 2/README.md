# Baldur's Gate II: Enhanced Edition — Mod Collection

> **Personal use** — mod collection, install scripts, and documentation for BG2:EE multiplayer (LAN, 4-6 players).

## What's Included

| Folder | Contents |
|---|---|
| `scripts/` | Install scripts (.bat, .ps1) + known-good `weidu.exe` |
| `docs/` | Full mod plan + installer documentation |
| `config/` | Reference `WeiDU.log` (99 components) + `weidu.conf` |
| `mods/` | Mod source files (13 of 14 — Warlock too large for GitHub) |

## Installed Mods (8 working, 99 components)

| # | Mod | Version | Components | Status |
|---|---|---|---|---|
| 1 | Spell Revisions | v4.20 | 1 (main) | ✅ |
| 2 | IWDification | v11 | 4 (Arcane + Divine spell packs + cosmetic) | ✅ |
| 3 | Artisan's Kitpack | master | 49 (all kits) | ✅ |
| 4 | Shadow Magic | master | 2 (main + Shade Lord) | ✅ |
| 5 | Bardic Wonders | master | 11 (all bard kits) | ✅ |
| 6 | Unfinished Business | v28 | 26 (all quests + items) | ✅ |
| 7 | Item Revisions | v3.0.17 | 1 (main — requires .tp2 patch) | ✅ |
| 8 | Tweaks Anthology | v18 | 9 (QOL only) | ✅ |

### Not installed (compatibility issues)

| Mod | Issue |
|---|---|
| Ascension | Must install BEFORE Spell Revisions (install order conflict) |
| Warlock | Install error — needs investigation |
| Wheels of Prophecy | Source code errors during install |
| Item Pack | Missing translation strings |
| Talents of Faerûn | Setup exe gives 16-bit error; use weidu.exe |
| BG2 Fixpack | Skips on EE (built-in fixes — normal behavior) |

## Correct Install Order

```
1. BG2 Fixpack          (will skip on EE — normal)
2. Ascension            ← MUST be here if used, BEFORE Spell Revisions
3. Spell Revisions
4. Item Revisions       (requires ENGINE_IS patch — see below)
5. IWDification
6. Artisan's Kitpack
7. Bardic Wonders
8. Shadow Magic
9. Warlock
10. Talents of Faerûn
11. Wheels of Prophecy
12. Unfinished Business
13. Item Pack
14. Tweaks Anthology    (always last)
```

## Component Numbers (for force-install)

These are the **DESIGNATED** numbers discovered through testing — use with `--force-install-list`:

### IWDification
```
30 = IWD Arcane Spell Pack (30+ new arcane spells)
40 = IWD Divine Spell Pack (40+ new divine spells)
```
**NOT** 10/20 — those are cosmetic components (Casting Graphics, Commoner Colors).

### Artisan's Kitpack
```
1 2 1000 1001 1003 1004 1005 1006 1007 1008 1009 1010 1100
2000 2010 2011 2012 2002 2003
3000 3010 3003 3011 3004 3001 3002 3005
5001 5002 5100 5110 5200 5300
7000 7001 7002 7003 7004 7005 7006 7007 7008
8001 8002 8101 9001 10001 10002 20000 20001
```

### Bardic Wonders
```
1001 1002 1003 1004 1005 1006 1007 1008 1009 1010 1011
```

### Shadow Magic
```
0 4 5 8    (main + No Resource Cost + Shadow Monk + Enhanced Shade Lord)
```

### Ascension (if installed before Spell Revisions)
```
0 10 20 30 40 50 60    (skip 1000+ = Tougher Enemies)
```

### Tweaks Anthology (QOL only)
```
10    = Remove Helmet Animations
1120  = Stores Sell Higher Stacks
1310  = Restore BG2 Spells
2140  = Expanded Dual-Class Options
2250  = Un-Nerfed Sorcerer
2351  = Allow non-humans all multiclass combos
3080  = Unlimited ammo stacking
3090  = Unlimited jewelry/gem stacking
3100  = Unlimited potion stacking
3110  = Unlimited scroll stacking
```

## Critical Flags for Non-Interactive Install

All setup exes need these flags or they fail silently:

```
setup-modname.exe --noautoupdate --use-lang en_US --language 0 --force-install-list <numbers>
```

- `--noautoupdate` — prevents WeiDU auto-update interference
- `--use-lang en_US` — sets game language without prompting

## Known Issues & Fixes

### 1. Item Revisions: "requires ToB" on BG2:EE

**Problem**: `REQUIRE_PREDICATE (ENGINE_IS ~tob~)` doesn't match BG2:EE.

**Fix**: Patch `item_rev/item_rev.tp2` — add `bg2ee eet` to all ENGINE_IS checks:
```
ENGINE_IS ~tob~  →  ENGINE_IS ~tob bg2ee eet~
ENGINE_IS ~soa tob~  →  ENGINE_IS ~soa tob bg2ee eet~
```
See `scripts/` for a Python script that does this automatically.

### 2. Setup exes giving "16-bit application" error

**Problem**: Some self-extracting WeiDU installers (ToF, Wheels, Item Pack) fail on 64-bit Windows.

**Fix**: Use `weidu.exe` instead:
```
weidu.exe <modfolder>/<modname>.tp2 --noautoupdate --use-lang en_US --language 0 --force-install <N>
```

### 3. Ascension: macOS exe in the zip

**Problem**: `ascension-2.1.0.zip` contains a Mach-O (macOS) binary named `Setup-Ascension.exe`.

**Fix**: Use `weidu.exe` to process `ascension/ascension.tp2` directly.

### 4. .tp2 files with "setup-" prefix

**Problem**: WeiDU looks for `modname.tp2` (no prefix), but some mods ship as `setup-modname.tp2`.

**Fix**: Copy/rename:
```
cp modfolder/setup-modname.tp2 modfolder/modname.tp2
```

### 5. Double-nested folders

**Problem**: Extracting mod zips creates `modfolder/modfolder/files` instead of `modfolder/files`.

**Fix**: Flatten inner folder:
```
cp -r modfolder/modfolder/* modfolder/
```

## Mod Download Links

| Mod | Source |
|---|---|
| Spell Revisions | https://github.com/Gibberlings3/SpellRevisions/releases |
| Item Revisions | https://github.com/Gibberlings3/ItemRevisions/releases |
| IWDification | https://github.com/Gibberlings3/iwdification/releases |
| Tweaks Anthology | https://github.com/Gibberlings3/Tweaks-Anthology/releases |
| Ascension | https://github.com/Gibberlings3/Ascension/releases |
| Wheels of Prophecy | https://github.com/Gibberlings3/WheelsOfProphecy/releases |
| Unfinished Business | https://github.com/Pocket-Plane-Group/UnfinishedBusiness/releases |
| BG2 Fixpack | https://github.com/Gibberlings3/BG2-Fixpack/releases |
| Talents of Faerûn | https://github.com/Gibberlings3/TalentsOfFaerun/releases |
| Artisan's Kitpack | https://artisans-corner.com/the-artisans-kitpack/ |
| Bardic Wonders | https://artisans-corner.com/bardic-wonders/ |
| Shadow Magic | https://artisans-corner.com/shadow-magic/ |
| Warlock | https://artisans-corner.com/warlock/ |
| Item Pack | https://github.com/Dau1makan/Item-Pack/releases |

## How to Reproduce This Install

1. Install clean BG2:EE from Steam
2. Launch once, create a save, close game
3. Copy all mod files from `mods/` into the game directory
4. Copy `scripts/weidu.exe` into the game directory
5. Fix .tp2 naming (see Known Issues #4)
6. Patch Item Revisions .tp2 (see Known Issues #1)
7. Run installers in order (see Correct Install Order)
8. Use the correct flags and component numbers
9. For mods with broken setup exes, use weidu.exe (see Known Issues #2)

## For LAN Multiplayer

- Copy the entire modded game folder to each player's machine
- All players must have **identical** WeiDU.log files
- Host creates game via Direct IP, players join
- Do NOT use Steam "Verify Game Files" — it will remove all mods
- Launch via `Baldur.exe` directly, not Steam
