# BG2:EE Mod Plan — LAN Multiplayer Party Play

## TL;DR

> **Quick Summary**: Install a curated set of 12 WeiDU mods that add more spells, classes, quests, and items to your BG2:EE install, while keeping combat close to vanilla feel. All mods verified compatible with BG2:EE multiplayer — the critical multiplayer rule is that **every LAN player must have an identical mod install**.
>
> **Deliverables**:
> - Modded BG2:EE install folder (yours, hostable)
> - Identical copies distributed to 3-5 other players
> - A tested LAN session working with full content
>
> **Estimated Effort**: Medium (2-3 hours for first install + testing, then ~30 min copy to each player)
> **Parallel Execution**: NO (all installs must be identical, but installation can be parallelized across machines after one host install is finalized)
> **Critical Path**: Backup → Install mods via Project Infinity → Test singleplayer → Distribute to players → LAN test

---

## Context

### Original Request
"For this installation of steam Baldur's Gate II:EE can you find me mods that are applicable/will work? I like more spells/classes/quests/items."

### Follow-Up Requirements
- **Format**: LAN multiplayer, 4-6 players
- **Difficulty**: Core Rules (vanilla+ feel, no major difficulty boost)
- **Scope**: Full Shadows of Amn + Throne of Bhaal
- **Excluded**: Workshop Kitpack (Soulsborne), Faiths and Powers, Talents of Faerûn Favored Soul class

### Research Findings
- **Multiplayer compatibility is high** for content mods — spells, items, classes, quests, tweaks all work fine
- **Critical multiplayer rule**: every LAN player must have identical mods with identical component selections, or the game desyncs
- Spell Revisions, Item Revisions, IWDification all confirmed MP-safe
- SCS recommended for MP (everyone shares the difficulty), but user wants vanilla+ feel — so SCS is optional with cosmetic/core AI components only
- SoD-to-BG2EE Item Upgrade mod is **not applicable** here (requires a SoD save to import from; user has BG2:EE standalone)
- Project Infinity is the standard tool for batch mod installation with order-checking

---

## Work Objectives

### Core Objective
Create a single, complete, MP-safe modded BG2:EE install that adds more spells, classes, quests, and items for a 4-6 player LAN campaign, then distribute identical copies to all players.

### Concrete Deliverables
- 1 working modded BG2:EE install (host machine)
- 3-5 identical copies of that install on the other players' machines
- A tested, working LAN session with full content available
- A reference document (this plan) for future reinstalls

### Definition of Done
- [ ] Host can start a multiplayer game and have other players join via Direct IP
- [ ] All 4-6 players see the new classes/kits available at character creation
- [ ] Casters in the party have new spells appear in their spellbook selection screens
- [ ] At least 1 new quest trigger is reachable in Shadows of Amn
- [ ] At least 1 new item appears in shops / as quest reward
- [ ] All players have identical `WeiDU.log` files (mod list verification)
- [ ] One complete test encounter works without crashes or desyncs

### Must Have
- All 4 categories of interest covered: spells, classes, quests, items
- Multiplayer-safe mods only
- Install method that produces an identical WeiDU.log on every machine
- Mods actively maintained (compatibility with current BG2:EE 2.6+)
- No major difficulty spike (Core Rules feel)

### Must NOT Have
- Single-player-only mods (romance mods, etc.)
- SoD-dependent mods (user has BG2:EE standalone)
- Mods that override the basic spell/item system in ways that break SCS-style enemy scripting (mitigated by skipping SCS tactical components)
- Major lore overhauls (Faiths and Powers, ToF Favored Soul) — excluded per user preference
- Difficulty-boosting components from SCS

### Scope Boundaries
- **IN**: BG2:EE (Shadows of Amn + Throne of Bhaal), 12 mods, LAN multiplayer setup, install instructions
- **OUT**: BG1:EE / Siege of Dragonspear, single-player-only mods, romance mods, NPC mods that add party-joinable NPCs that don't work cleanly in MP, NPC/banter mods, portrait packs

---

## Multiplayer LAN Setup Strategy

### Why All Players Need Identical Installs
The BG2:EE multiplayer engine synchronizes game state between clients. If Player A has Spell Revisions installed and Player B does not:
- Player B's client may not understand new spell IDs
- Spell scrolls, items, and effects may behave inconsistently
- Quest triggers may not fire on all clients
- Result: crashes, desyncs, broken encounters

**Rule**: Every player must have identical mods with identical components selected.

### Recommended Setup Workflow

**Phase 1: Host Prepares the Install (one-time)**
1. Backup your clean BG2:EE Steam install
2. Install BG2:EE from Steam
3. Launch the game once and create/load a save — this generates the config files
4. Close the game completely
5. Install **Project Infinity** (mod manager)
6. Download all 12 mods to a single staging folder
7. Configure mod load order in Project Infinity (see Install Order below)
8. Run the installer
9. Launch single-player, verify mods work (check character creation screen, etc.)
10. Once verified, your install is the "master"

**Phase 2: Distribute to Other Players**
Three viable methods (pick one):

| Method | Pros | Cons |
|---|---|---|
| **Copy game folder via LAN** | Fastest after first setup; large transfer but fast on LAN | Requires LAN file sharing setup |
| **External USB drive** | Most reliable; no network needed | Manual drive swap |
| **Each player runs installer** | Smallest transfer (just mod files) | Highest chance of human error; install order mistakes |

**Recommended**: Copy the entire modded game folder. Once one install is verified, copy it to the other 3-5 machines. This guarantees identical installs.

**Phase 3: Verify Before LAN Session**
Each player should:
1. Launch single-player from their modded install
2. Confirm a few key mods are loaded (check character creation, spellbook)
3. Compare `WeiDU.log` files — they should be byte-identical (mod list + component selections)

**Phase 4: LAN Session**
1. Host starts a new multiplayer game, selects Direct IP
2. Host shares their IP address with other players
3. Other players join via Direct IP
4. All players create characters in the lobby
5. Begin campaign — everyone should see identical content

---

## The Final Mod List (Curated for Multiplayer)

### Tier 1: Foundation (Install First)

| # | Mod | Why |
|---|---|---|
| 1 | **BG2 Fixpack** | Bug fixes for BG2:EE — must install before anything that touches affected files |
| 2 | **The Tweaks Anthology** | ~20 quality-of-life components; install near the end so it can tweak items/spells added by other mods |

### Tier 2: Core Content (Install in Order)

| # | Mod | What it adds | Multiplayer-safe? |
|---|---|---|---|
| 3 | **Spell Revisions** (SR) | Rebalances ~150 existing spells + ~50 new spells | YES (confirmed in multiple MP tests) |
| 4 | **Item Revisions** | Rebalances existing items; buffs weak items, nerfs overpowered ones | YES |
| 5 | **IWDification** | 70+ new spells from Icewind Dale (arcane + divine packs) | YES |
| 6 | **Talents of Faerûn** (kit/class revisions + multiclass kits only) | Kit revisions and ~70 multiclass kits. **Do NOT install**: Favored Soul class, deity customization, sphere system, high-level abilities overhaul (excluded per user) | YES (data-only) |
| 7 | **The Artisan's Kitpack** | Many new kits + reworks (Berserker, Kensai, Arcane Archer, etc.) | YES |
| 8 | **Bardic Wonders** | New bard kits + unique songs | YES |

### Tier 3: Quests & Items

| # | Mod | What it adds | Multiplayer-safe? |
|---|---|---|---|
| 9 | **Ascension** | Rewrites Throne of Bhaal finale; tougher enemies, redeemable Balthazar | YES (confirmed MP-compatible with caveats for some components) |
| 10 | **Wheels of Prophecy** | Non-linear ToB chapter 9; expanded dialogue, alternate routes | YES (designed as Ascension companion) |
| 11 | **Unfinished Business** | Restores cut quests, encounters, and items from BG2 vanilla | YES |
| 12 | **Item Pack** | 45+ brand-new items scattered throughout the game | YES |

### Optional (Core Rules Feel — Skip If You Want Pure Vanilla+)

- **Sword Coast Stratagems (SCS)** — if you want smarter enemy AI without difficulty increase:
  - Install ONLY the "cosmetic/ease-of-use" components and "Smarter Mages/Priests" core components
  - **DO NOT** install tactical difficulty components (Tactical Challenges, Tougher Enemies, etc.)
  - For purest vanilla+ feel, skip SCS entirely

### Explicitly Excluded

- Workshop Kitpack (Soulsborne theme — user exclusion)
- Faiths and Powers (lore overhaul — user exclusion)
- ToF Favored Soul class + deity system (lore overhaul — user exclusion)
- SoD-to-BG2EE Item Upgrade (requires SoD install — user doesn't have SoD)
- Romance mods (single-player-focused)
- NPC Project / banter mods (don't add value in MP party setup)
- Portrait packs (cosmetic, no content value)

---

## Install Order

This order is critical — installing mods in the wrong order causes silent overwrites and broken content.

```
1. BG2 Fixpack                              [Foundation - first]
2. Spell Revisions                          [Spell data - early]
3. Item Revisions                           [Item data - early, before items-adding mods]
4. IWDification                             [More spell data - after SR so IWD doesn't overwrite SR]
5. Talents of Faerûn (kit/multiclass only)  [Class data - after spell mods]
6. The Artisan's Kitpack                    [Kit data - after ToF]
7. Bardic Wonders                           [Kit data - after Artisan's]
8. Ascension                                [Quest - early in quests]
9. Wheels of Prophecy                       [Quest - after Ascension]
10. Unfinished Business                     [Quest+item - mid-late]
11. Item Pack                               [Item - before Tweaks]
12. The Tweaks Anthology                    [Tweaks - LAST, so it can patch items added above]
--- OPTIONAL ---
13. SCS (cosmetic + Smarter AI only)        [AI - last so it reads all final spell data]
```

**Why this order**:
- Spell Revisions comes before IWDification because SR's spells should win on conflict (per maintainer guidance)
- Item Revisions comes early because it overwrites base items
- ToF kit/multiclass before Artisan's Kitpack because ToF's class revisions affect which kits Artisan's adds
- Ascension before Wheels of Prophecy (Wheels assumes Ascension is present)
- Tweaks Anthology LAST — its item tweaks need to apply to the final state of items
- SCS last because it reads the final spell data to script enemy behavior

---

## Per-Player Setup Instructions

### For the Host

**Step 1: Backup**
```
1. Right-click BG2:EE in Steam → Manage → Browse local files
2. Copy the entire "Baldur's Gate II Enhanced Edition" folder
3. Save as "BG2EE_Clean_Backup" somewhere safe
```

**Step 2: Prepare the Game**
```
1. Launch BG2:EE from Steam
2. Wait for the main menu
3. Start a new game, create a character, immediately quit to main menu
4. Save your game
5. Close the game entirely (close from system tray if needed)
```

**Step 3: Install Project Infinity**
```
1. Download Project Infinity from the Beamdog forums:
   https://forums.beamdog.com/discussion/74335/
2. Extract to a folder outside the BG2:EE directory
3. Launch ProjectInfinity.exe
```

**Step 4: Download Mods**
Download each of the 12 mods from their official sources. Extract each to a single staging folder. Recommended staging structure:
```
D:\BG2_ModStaging\
├── spell_rev\
├── item_rev\
├── iwdification\
├── TalentsOfFaerun\
├── artisanskitpack\
├── bardicwonders\
├── Ascension\
├── WheelsOfProphecy\
├── UnfinishedBusiness\
├── ItemPack\
├── TweaksAnthology\
└── BG2Fixpack\
```

Download sources:
- Gibberlings3: https://www.gibberlings3.net/
- Spellhold Studios: https://www.shsforums.net/
- GitHub (search for mod name + author)

**Step 5: Configure Project Infinity**
```
1. In Project Infinity, point to:
   - Mod folder: D:\BG2_ModStaging\
   - Game folder: D:\SteamLibrary\steamapps\common\Baldur's Gate II Enhanced Edition\
2. Refresh — all 12 mods should appear
3. Drag-and-drop mods into the install sequence in the exact order listed in the "Install Order" section above
4. Click "Set Installation Sequence" — should pass with no order errors
5. Select the components per the "Component Selections" section below
6. Click "Start Installation"
```

**Step 6: Component Selections** (important — must match across all players)
- **BG2 Fixpack**: Install core component
- **Spell Revisions**: Main component + "Update NPC Spellbooks"
- **Item Revisions**: Main component only (skip optional rule-changing components for now)
- **IWDification**: Arcane Spell Pack + Divine Spell Pack only (skip "Class Updates" to avoid conflicts with kit mods)
- **Talents of Faerûn**: SKIP Favored Soul, SKIP deity/sphere system, SKIP high-level ability overhaul. INSTALL: kit/class revisions and multiclass kits components
- **The Artisan's Kitpack**: All components
- **Bardic Wonders**: All components
- **Ascension**: Install core + redeemable Balthazar + restored Bhaalspawn powers (skip "Tougher Enemies" sub-components for Core Rules feel)
- **Wheels of Prophecy**: Install core
- **Unfinished Business**: Quest restorations + item restorations + dialogue restorations (skip NPC portrait restorations — cosmetic)
- **Item Pack**: Main component (45 new items)
- **The Tweaks Anthology**: Selected components — see below
- **SCS** (optional): Install ONLY Smarter Mages + Smarter Priests + a few cosmetic components. SKIP all tactical difficulty components

**Tweaks Anthology recommended components** (select these during install):
- "Remove Helmet Animations" (cosmetic)
- "Allow Edwin to Use Amulets and Rings" (QOL)
- "Allow Thieves to Use Scrolls at Level 1" (QOL)
- "Increase Ammo Stacking" (QOL)
- "Increase Gem and Jewelry Stacking" (QOL)
- "Increase Potion Stacking" (QOL)
- "Stackable Rings, Amulets, etc." (QOL)
- "Restored BG2 Spells and Make Scrolls Available" (spell availability)
- "Level-Lock Spell Scrolls [Angel]" (balance)
- "Un-Nerfed Sorcerer Spell Progression Table" (quality of life for sorcerers)
- "Alter Multi-Class Restrictions" (more multiclass options)
- "Alter Dual-Class Restrictions" (more dual-class freedom)
- Skip: anything that changes difficulty or removes content

**Step 7: Single-Player Test**
```
1. Launch BG2:EE
2. Start a new game in Shadows of Amn
3. At character creation, verify:
   - Can see new kits from Artisan's Kitpack, ToF, Bardic Wonders
   - Favored Soul class NOT present (we excluded it)
4. Create a mage or cleric character
5. Level up to level 2, check spellbook — should see new spells from SR + IWDification
6. Visit a shop, browse — should see some new items from Item Pack
7. Save the game
```

**Step 8: Verify WeiDU.log**
```
1. Navigate to your BG2:EE folder
2. Open "WeiDU.log" in a text editor
3. Confirm all 12 mods are listed with the correct components
4. This file is your "install fingerprint" — other players' copies should match
```

### For Each Other Player

**Option A: Copy Entire Modded Folder (Recommended)**

```
1. Copy the host's entire BG2:EE folder to their machine
   - Recommended location: same Steam path (D:\SteamLibrary\steamapps\common\Baldur's Gate II Enhanced Edition\)
2. They launch Steam → Library → Right-click BG2:EE → Properties → Local Files → "Verify integrity of game files"
   - This will say files mismatch (because of mods) — DO NOT have Steam "fix" them, this will overwrite mods
   - Instead: have them launch the game directly by running Baldur.exe from the modded folder
   - OR: have Steam "Verify" once to generate config files, then re-copy the modded folder over the top
3. They launch BG2:EE once to generate their own config files
4. They run single-player briefly to confirm mods loaded
5. They compare WeiDU.log with host's — must match
```

**Option B: Each Player Runs the Installer**

```
1. Each player installs BG2:EE from Steam
2. Each player runs Project Infinity with the EXACT same staging folder and component selections as the host
3. Risk: human error in component selection. Use a screenshot or shared notes from the host.
```

---

## LAN Session Setup

### Host Setup
```
1. Open BG2:EE
2. Click "Multiplayer" → "Create New Game"
3. Choose "Direct IP" (not Beamdog network services)
4. Note your local IP address:
   - Press Win+R, type "cmd", press Enter
   - Type "ipconfig" and find your IPv4 address (e.g., 192.168.1.100)
5. Share this IP with the other players
6. Wait for players to join
7. Once everyone is in the lobby, start the game
```

### Client Setup
```
1. Open BG2:EE
2. Click "Multiplayer" → "Join Game"
3. Choose "Direct IP"
4. Enter the host's IP address
5. Wait for connection
6. Create your character in the lobby
```

### Common LAN Issues

| Issue | Cause | Fix |
|---|---|---|
| Can't connect to host | Firewall blocking BG2:EE | Add Baldur.exe to Windows Firewall exceptions on the host machine |
| Game crashes on join | Different mod installs | Verify all WeiDU.log files are identical |
| Spells show as "Invalid" string | Player missing Spell Revisions or IWDification | Reinstall matching mods |
| Different items appear | Player missing Item Revisions or Item Pack | Reinstall matching mods |
| Quest won't progress for one player | Mismatched quest mods (Ascension/WoP) | Reinstall matching mods |

---

## Verification Checklist

Before launching your LAN campaign, each player should confirm:

- [ ] WeiDU.log matches the host's exactly
- [ ] Character creation screen shows new kits (Arcane Archer reworks, ToF multiclass kits, Bardic Wonders bard kits)
- [ ] Favored Soul class does NOT appear (we excluded it)
- [ ] Starting a mage, level to 2, see at least one new spell from SR or IWDification
- [ ] Starting a cleric, level to 3, see at least one new divine spell
- [ ] Visit Adventurer's Mart or other shop — see at least one new item from Item Pack
- [ ] Reach Chapter 2 trigger — see no quest-breaking messages
- [ ] Play through first dungeon (Irenicus Dungeon) — no crashes

---

## Troubleshooting Reference

### Project Infinity Says "Install Order Error"
You have two mods in the wrong sequence. The most common causes:
- Tweaks Anthology before item-adding mods (move it later)
- Spell Revisions after IWDification (swap them)
- Artisan's Kitpack before ToF (swap them)

### Game Crashes on Launch After Modding
Most likely a missing dependency. Check:
- Did BG2 Fixpack install successfully?
- Did you install in the exact order?
- Re-run Project Infinity with the same config — it should be idempotent

### Multiplayer Desync Mid-Game
Players have different installs. Verify by:
1. Each player exports their WeiDU.log
2. Use a diff tool to compare them
3. Any difference means someone needs to reinstall

### Want to Add More Mods Later
1. Backup current state
2. Use Project Infinity's "Import WeiDU.log" feature
3. Add the new mod(s) at the end of the install sequence
4. Run the installer
5. Distribute the updated folder to all players

---

## File Locations Reference

| What | Where |
|---|---|
| BG2:EE game folder | `D:\SteamLibrary\steamapps\common\Baldur's Gate II Enhanced Edition\` |
| WeiDU.log (install fingerprint) | Same folder, `WeiDU.log` |
| Backup (recommended) | `D:\BG2EE_Clean_Backup\` (or anywhere outside SteamLibrary) |
| Mod staging folder | `D:\BG2_ModStaging\` |
| Project Infinity | Extract to `D:\ProjectInfinity\` (NOT inside BG2:EE folder) |

---

## Success Criteria

### Per-Player Verification Commands
```bash
# Each player should run these after install:
dir "D:\SteamLibrary\steamapps\common\Baldur's Gate II Enhanced Edition\setup-*.exe"
# Expected: 12 setup-*.exe files (one per mod), each WeiDU installer

# Check WeiDU.log mod count:
findstr /C:"MODIFYING" "D:\SteamLibrary\steamapps\common\Baldur's Gate II Enhanced Edition\WeiDU.log"
# Should show entries for all 12 mods
```

### Final Checklist
- [ ] All 12 mods installed with matching component selections
- [ ] Single-player test passes for each player
- [ ] WeiDU.log files are identical across all machines
- [ ] LAN connection works (host can see all players in lobby)
- [ ] No crashes in Irenicus Dungeon (first MP encounter)
- [ ] At least one player can demonstrate a new spell from SR or IWDification
- [ ] At least one player can demonstrate a new kit from Artisan's Kitpack
- [ ] All players see Ascension content when reaching ToB

---

## Notes & Future Considerations

- **Reinstalls are easy**: If you want to start over with different mod choices, restore from the clean backup and re-run Project Infinity
- **Adding mods later**: Always use Project Infinity's import feature to maintain a valid install order
- **Save game compatibility**: Major mod changes will break save games. Plan major mod changes around starting a new campaign
- **Single-player after LAN**: Your modded install works for single-player too — just don't use it to overwrite another player's modded install

If you'd like a future iteration that adds (or removes) specific mods, or targets a different difficulty, this plan can be re-used as a starting framework.
