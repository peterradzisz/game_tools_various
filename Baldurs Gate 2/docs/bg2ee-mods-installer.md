# BG2:EE Mod Installer Script — Companion to `bg2ee-mods.md`

This document contains a complete PowerShell script that automates downloading, extracting, and installing the 12 mods from your mod plan (`bg2ee-mods.md`).

> **Why a script inside markdown?** Prometheus (the planner) only writes `.md` files. You copy the script block below into a `.ps1` file and run it — takes about 10 seconds.

---

## Quick Start (3 Steps)

### Step 1: Save the script

1. Open Notepad (or PowerShell ISE, VS Code, anything)
2. Copy everything inside the `<powershell-script>` block below
3. Save it as `Install-BG2EE-Mods.ps1` in a convenient location (e.g., `D:\BG2_ModStaging\Install-BG2EE-Mods.ps1`)

### Step 2: Open PowerShell as Administrator

- Press `Win + X`, choose "Windows PowerShell (Admin)"
- Required because we're writing to Steam library paths

### Step 3: Run the script

```powershell
# Allow scripts for this session only (resets when you close the window)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Navigate to where you saved the script
cd D:\BG2_ModStaging

# Run it
.\Install-BG2EE-Mods.ps1
```

The script will:
1. Verify your BG2:EE install exists
2. Back up your clean game folder (optional but recommended)
3. Download all GitHub-hosted mods automatically
4. Open your browser for the 3 mods that aren't on GitHub
5. Extract everything
6. Copy mod files into your BG2:EE folder
7. Run each WeiDU installer in the correct order
8. For complex mods, it pauses and shows you exactly which components to select

**Total time**: ~30-60 min depending on download speed.

---

## Before You Run the Script

### What the script will and won't do

| Does | Does NOT do |
|---|---|
| Download GitHub-hosted mods automatically | Auto-install Artisan's Kitpack / Bardic Wonders / Item Pack (opens browser instead) |
| Create a backup of your BG2:EE folder | Modify your Steam install of BG2:EE (only the local game folder) |
| Extract all `.zip` archives | Install Siege of Dragonspear |
| Copy mod folders to the game directory | Install mods you didn't approve |
| Run installers in correct order | Force-install components without your approval for complex mods |
| Verify `WeiDU.log` at the end | Auto-distribute to other LAN players |

### Manual downloads required (script opens browser, you save files)

When the script runs, it will open your browser to these pages. Download the latest Windows `.exe` or `.zip` and save them to `D:\BG2_ModStaging\downloads\`:

1. **The Artisan's Kitpack** — https://artisans-corner.com/the-artisans-kitpack/
2. **Bardic Wonders** — https://artisans-corner.com/bardic-wonders/
3. **Item Pack** — https://github.com/Dau1makan/Item-Pack/releases

The script pauses after opening each browser tab and waits for you to press Enter once the file is downloaded.

---

## The PowerShell Script

Copy everything between the `<powershell-script>` markers below into a file named `Install-BG2EE-Mods.ps1`.

<powershell-script>

```powershell
<#
.SYNOPSIS
    BG2:EE Mod Installer for LAN Multiplayer Party Play
.DESCRIPTION
    Downloads, extracts, and installs a curated set of 12 mods for Baldur's Gate II: Enhanced Edition.
    Companion to the plan at .omo/plans/bg2ee-mods.md.
.NOTES
    Run as Administrator.
#>

# ============================================================
# CONFIGURATION — adjust these if your paths differ
# ============================================================

$Config = @{
    GamePath    = "D:\SteamLibrary\steamapps\common\Baldur's Gate II Enhanced Edition"
    StagingPath = "D:\BG2_ModStaging"
    BackupPath  = "D:\BG2EE_Clean_Backup"
    Language    = "0"   # 0 = English
    SkipBackup  = $false
}

# ============================================================
# MOD DEFINITIONS
# Each mod has:
#   Name, Repo (GitHub owner/repo, or $null for manual), AssetPattern (regex),
#   FolderName, SetupExe, Install ("auto" or "interactive"), Sort (install order)
# ============================================================

$Mods = @(
    @{
        Name="BG2 Fixpack (EE Fixpack)"
        Repo=$null
        ManualUrl="https://www.gibberlings3.net/mods/fixes/fixpack/"
        FolderName="fixpack"
        SetupExe="setup-fixpack.exe"
        Install="interactive"
        Sort=1
        Note="Install all default components."
    }
    @{
        Name="Spell Revisions"
        Repo="Gibberlings3/SpellRevisions"
        AssetPattern="spell_rev-.*\.zip$"
        FolderName="spell_rev"
        SetupExe="setup-spell_rev.exe"
        Install="interactive"
        Sort=2
        Note="Install: main 'Spell Revisions' component + 'Update Spellbooks of Joinable NPCs'."
    }
    @{
        Name="Item Revisions"
        Repo="Gibberlings3/ItemRevisions"
        AssetPattern="item_rev-.*\.zip$"
        FolderName="item_rev"
        SetupExe="setup-item_rev.exe"
        Install="interactive"
        Sort=3
        Note="Install: main component only. Skip optional rule-changing components."
    }
    @{
        Name="IWDification"
        Repo="Gibberlings3/iwdification"
        AssetPattern="iwdification-.*\.zip$"
        FolderName="iwdification"
        SetupExe="setup-iwdification.exe"
        Install="interactive"
        Sort=4
        Note="Install ONLY: 'Arcane Spell Pack' + 'Divine Spell Pack'. Skip 'Class Updates' to avoid kit conflicts."
    }
    @{
        Name="Talents of Faerun (kit/multiclass only)"
        Repo="Gibberlings3/TalentsOfFaerun"
        AssetPattern="dw_talents-.*\.zip$|TalentsOfFaerun-.*\.zip$"
        FolderName="dw_talents"
        SetupExe="setup-dw_talents.exe"
        Install="interactive"
        Sort=5
        Note="INSTALL: Class/Kit Revisions + Multiclass/Dual-Class Kits. SKIP: Favored Soul class, deity/sphere system, HLA overhaul."
    }
    @{
        Name="The Artisan's Kitpack"
        Repo=$null
        ManualUrl="https://artisans-corner.com/the-artisans-kitpack/"
        FolderName="artisanskitpack"
        SetupExe="setup-artisanskitpack.exe"
        Install="interactive"
        Sort=6
        Note="Install all components."
    }
    @{
        Name="Bardic Wonders"
        Repo=$null
        ManualUrl="https://artisans-corner.com/bardic-wonders/"
        FolderName="bardicwonders"
        SetupExe="setup-bardicwonders.exe"
        Install="interactive"
        Sort=7
        Note="Install all components."
    }
    @{
        Name="Ascension"
        Repo="Gibberlings3/Ascension"
        AssetPattern="ascension-.*\.zip$"
        FolderName="ascension"
        SetupExe="setup-ascension.exe"
        Install="interactive"
        Sort=8
        Note="Install: 'The Ascension' core + 'Redeemable Balthazar' + 'Restored Bhaalspawn Powers'. SKIP 'Tougher Enemies' (Core Rules)."
    }
    @{
        Name="Wheels of Prophecy"
        Repo="Gibberlings3/WheelsOfProphecy"
        AssetPattern="wheels.*\.zip$|WheelsOfProphecy.*\.zip$"
        FolderName="wheels_of_prophecy"
        SetupExe="setup-wheels_of_prophecy.exe"
        Install="interactive"
        Sort=9
        Note="Install: main/only component."
    }
    @{
        Name="Unfinished Business"
        Repo="Pocket-Plane-Group/UnfinishedBusiness"
        AssetPattern="ub-.*\.zip$|UnfinishedBusiness.*\.zip$"
        FolderName="ub"
        SetupExe="setup-ub.exe"
        Install="interactive"
        Sort=10
        Note="Install: Quest Restorations + Item Restorations + Dialogue Restorations. SKIP NPC Portrait Restorations (cosmetic)."
    }
    @{
        Name="Item Pack"
        Repo=$null
        ManualUrl="https://github.com/Dau1makan/Item-Pack/releases"
        FolderName="ItemPack"
        SetupExe="setup-ItemPack.exe"
        Install="interactive"
        Sort=11
        Note="Install: main component (45 new items)."
    }
    @{
        Name="The Tweaks Anthology"
        Repo="Gibberlings3/Tweaks-Anthology"
        AssetPattern="cdtweaks-.*\.exe$"
        FolderName="cdtweaks"
        SetupExe="setup-cdtweaks.exe"
        Install="interactive"
        Sort=12
        Note="Pick QOL components per the plan (see 'Tweaks Anthology Selections' in the markdown doc)."
    }
) | Sort-Object Sort

# ============================================================
# HELPER FUNCTIONS
# ============================================================

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host " $Text" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
}

function Write-Step    { param([string]$Text) Write-Host "==> $Text" -ForegroundColor Yellow }
function Write-OK      { param([string]$Text) Write-Host "    [OK] $Text" -ForegroundColor Green }
function Write-Warn2   { param([string]$Text) Write-Host "    [!] $Text" -ForegroundColor Yellow }
function Write-Err2    { param([string]$Text) Write-Host "    [X] $Text" -ForegroundColor Red }

function Pause {
    Write-Host ""
    Write-Host "Press Enter to continue..." -ForegroundColor Gray
    [void][System.Console]::ReadLine()
}

function Get-LatestGitHubAsset {
    param(
        [Parameter(Mandatory=$true)][string]$Repo,
        [Parameter(Mandatory=$true)][string]$AssetPattern
    )
    $apiUrl = "https://api.github.com/repos/$Repo/releases/latest"
    try {
        $release = Invoke-RestMethod -Uri $apiUrl -Headers @{ "User-Agent" = "BG2-Mod-Installer" } -ErrorAction Stop
        foreach ($asset in $release.assets) {
            if ($asset.name -match $AssetPattern) {
                return @{
                    Url = $asset.browser_download_url
                    Name = $asset.name
                    Version = $release.tag_name
                }
            }
        }
        Write-Warn2 "No asset matched pattern '$AssetPattern' in $Repo latest release."
        return $null
    } catch {
        Write-Err2 "Failed to query GitHub API for $Repo : $_"
        return $null
    }
}

function Download-File {
    param([string]$Url, [string]$Destination)
    try {
        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing -ErrorAction Stop
        return $true
    } catch {
        Write-Err2 "Download failed: $_"
        return $false
    }
}

# ============================================================
# PHASE 0: PREREQUISITES
# ============================================================

Write-Header "BG2:EE Mod Installer - Phase 0: Prerequisites"

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Err2 "This script requires Administrator privileges."
    Write-Host "    Please close PowerShell and re-open it as Administrator."
    Pause
    exit 1
}
Write-OK "Running as Administrator"

if (-not (Test-Path $Config.GamePath)) {
    Write-Err2 "BG2:EE game folder not found at: $($Config.GamePath)"
    Write-Host "    Edit the script and set Config.GamePath to the correct location."
    Pause
    exit 1
}
if (-not (Test-Path (Join-Path $Config.GamePath "chitin.key"))) {
    Write-Err2 "chitin.key not found in game folder. Is BG2:EE installed correctly?"
    Pause
    exit 1
}
Write-OK "BG2:EE install found at $($Config.GamePath)"

$downloadsPath = Join-Path $Config.StagingPath "downloads"
$extractedPath = Join-Path $Config.StagingPath "extracted"
foreach ($p in @($Config.StagingPath, $downloadsPath, $extractedPath)) {
    if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
}
Write-OK "Staging folders ready at $($Config.StagingPath)"

# ============================================================
# PHASE 1: BACKUP
# ============================================================

Write-Header "Phase 1: Backup"

if ($Config.SkipBackup) {
    Write-Warn2 "Backup skipped (set in config)."
} elseif (Test-Path $Config.BackupPath) {
    Write-Warn2 "Backup already exists at $($Config.BackupPath) - skipping."
} else {
    $answer = Read-Host "Create backup of clean BG2:EE install to $($Config.BackupPath)? (Y/n)"
    if ($answer -ne "n" -and $answer -ne "N") {
        Write-Step "Copying game folder (this takes a minute)..."
        Copy-Item -Path $Config.GamePath -Destination $Config.BackupPath -Recurse -Force
        Write-OK "Backup created."
    } else {
        Write-Warn2 "Skipped backup. You can restore from Steam later if needed."
    }
}

# ============================================================
# PHASE 2: DOWNLOAD MODS
# ============================================================

Write-Header "Phase 2: Download Mods"

$manualDownloads = @()

foreach ($mod in $Mods) {
    Write-Step "[$($mod.Sort)/$($Mods.Count)] $($mod.Name)"

    if ($mod.Repo) {
        $asset = Get-LatestGitHubAsset -Repo $mod.Repo -AssetPattern $mod.AssetPattern
        if ($asset) {
            $destFile = Join-Path $downloadsPath $asset.Name
            if (Test-Path $destFile) {
                Write-OK "Already downloaded: $($asset.Name)"
            } else {
                Write-Host "    Downloading $($asset.Name) ($($asset.Version))..."
                if (Download-File -Url $asset.Url -Destination $destFile) {
                    Write-OK "Downloaded $($asset.Name)"
                } else {
                    $manualDownloads += $mod
                }
            }
        } else {
            $manualDownloads += $mod
        }
    } else {
        $manualDownloads += $mod
    }
}

if ($manualDownloads.Count -gt 0) {
    Write-Header "Manual Downloads Required"
    Write-Host "The following mods need manual download. The script will open browser tabs."
    Write-Host "Save each downloaded file to: $downloadsPath"
    Write-Host ""
    foreach ($mod in $manualDownloads) {
        Write-Step "Opening: $($mod.Name)"
        Write-Host "    URL: $($mod.ManualUrl)"
        Start-Process $mod.ManualUrl
        Write-Host "    -> Download the Windows .exe or .zip and save to:"
        Write-Host "       $downloadsPath"
        Pause
    }
}

Write-OK "All downloads complete."

# ============================================================
# PHASE 3: EXTRACT ARCHIVES
# ============================================================

Write-Header "Phase 3: Extract Archives"

$archives = Get-ChildItem -Path $downloadsPath -File | Where-Object { $_.Extension -in ".zip", ".7z", ".rar" }

foreach ($archive in $archives) {
    $extractTo = Join-Path $extractedPath $archive.BaseName
    Write-Step "Extracting $($archive.Name)..."
    if (Test-Path $extractTo) {
        Write-OK "Already extracted."
        continue
    }
    try {
        Expand-Archive -Path $archive.FullName -DestinationPath $extractTo -Force -ErrorAction Stop
        Write-OK "Extracted to $extractTo"
    } catch {
        Write-Err2 "Failed: $_"
        Write-Host "    Try extracting manually with 7-Zip."
    }
}

Write-OK "Extraction complete."

# ============================================================
# PHASE 4: COPY MOD FOLDERS TO GAME DIRECTORY
# ============================================================

Write-Header "Phase 4: Copy Mod Folders to Game Directory"

foreach ($mod in $Mods) {
    Write-Step "Locating folder for: $($mod.Name)"

    $foundFolder = $null
    $candidates = Get-ChildItem -Path $extractedPath -Directory -Recurse -ErrorAction SilentlyContinue |
                  Where-Object { $_.Name -match $mod.FolderName -or $_.Name -match ($mod.FolderName -replace "_","-") }
    if ($candidates) { $foundFolder = $candidates[0].FullName }

    # Self-extracting .exe (like cdtweaks)
    $selfExtractExe = Get-ChildItem -Path $downloadsPath -File -ErrorAction SilentlyContinue |
                      Where-Object { $_.Name -match ($mod.SetupExe -replace "setup-","" -replace "\.exe$","") }
    if (-not $foundFolder -and $selfExtractExe) {
        Write-OK "Self-extracting installer - copy to game folder..."
        Copy-Item -Path $selfExtractExe.FullName -Destination $Config.GamePath -Force
        Write-OK "Copied $($selfExtractExe.Name) to game folder."
        continue
    }

    if ($foundFolder) {
        $destFolder = Join-Path $Config.GamePath $mod.FolderName
        if (Test-Path $destFolder) {
            Write-OK "Already present in game folder."
        } else {
            Copy-Item -Path $foundFolder -Destination $destFolder -Recurse -Force
            Write-OK "Copied $($mod.FolderName) to game folder."
        }

        $setupExeSrc = Join-Path (Split-Path $foundFolder) $mod.SetupExe
        if (Test-Path $setupExeSrc) {
            Copy-Item -Path $setupExeSrc -Destination $Config.GamePath -Force
        }
    } else {
        Write-Warn2 "Could not find folder for $($mod.Name) in extracted files."
        Write-Host "    You may need to manually copy the mod folder to the game directory."
    }
}

# ============================================================
# PHASE 5: RUN WEIDU INSTALLERS IN ORDER
# ============================================================

Write-Header "Phase 5: Run Installers (in correct order)"
Write-Host "IMPORTANT: For each mod, follow the on-screen guidance for which components to select."
Write-Host ""

Push-Location $Config.GamePath

foreach ($mod in $Mods) {
    Write-Header "Installing [$($mod.Sort)/$($Mods.Count)]: $($mod.Name)"

    $setupPath = Join-Path $Config.GamePath $mod.SetupExe
    if (-not (Test-Path $setupPath)) {
        Write-Err2 "Setup executable not found: $($mod.SetupExe)"
        Write-Host "    Did you copy the mod folder correctly? Skipping."
        continue
    }

    Write-Host ""
    Write-Host "MOD GUIDANCE:" -ForegroundColor White
    Write-Host "  $($mod.Note)" -ForegroundColor White
    Write-Host ""

    Write-Step "Launching interactive installer..."
    Write-Host "  Select components per the guidance above. Type 'n' or 'y' at each prompt."
    Write-Host "  When finished, return to this window."
    Pause
    Start-Process -FilePath $setupPath -Wait

    Write-OK "Finished: $($mod.Name)"
}

Pop-Location

# ============================================================
# PHASE 6: VERIFY INSTALL
# ============================================================

Write-Header "Phase 6: Verify Install"

$weiduLog = Join-Path $Config.GamePath "WeiDU.log"
if (Test-Path $weiduLog) {
    Write-OK "WeiDU.log exists."
    $installed = Get-Content $weiduLog | Select-String "~"
    Write-Host ""
    Write-Host "Installed mods (from WeiDU.log):" -ForegroundColor White
    $installed | ForEach-Object { Write-Host "  $($_.Line)" }
    Write-Host ""
    Write-Host "Total components installed: $($installed.Count)" -ForegroundColor White
} else {
    Write-Err2 "WeiDU.log not found! No mods were installed?"
}

# ============================================================
# DONE
# ============================================================

Write-Header "Installation Complete"
Write-Host "Next steps:"
Write-Host "  1. Launch BG2:EE (run Baldur.exe directly, not via Steam)."
Write-Host "  2. Start a new single-player game and create a character."
Write-Host "  3. Verify you see the new kits and spells."
Write-Host "  4. Once verified, copy this entire game folder to other LAN players."
Write-Host "  5. See the main plan (.omo/plans/bg2ee-mods.md) for multiplayer setup."
Write-Host ""
Pause
```

</powershell-script>

---

## Tweaks Anthology Selections (Phase 5, Step 12)

When the Tweaks Anthology installer runs, it has ~400 components. Use these **recommended component names**:

**Quality-of-Life (select these):**
- "Remove Helmet Animations"
- "Allow Edwin to Use Amulets and Rings"
- "Increase Ammo Stacking" (pick max stacking)
- "Increase Gem and Jewelry Stacking"
- "Increase Potion Stacking"
- "Stackable Rings, Amulets, etc."

**Spell availability:**
- "Restore (Most) BG2 Spells and Make Scrolls Available"
- "Un-Nerfed Sorcerer Spell Progression Table"

**Class flexibility:**
- "Alter Multi-Class Restrictions"
- "Alter Dual-Class Restrictions"

**Skip these (keep Core Rules feel):**
- Anything labeled "Harder", "Difficult", or "Deadlier"
- Anything that removed or nerfs existing items
- "Maximum HP per level" (changes balance)

---

## Troubleshooting

### "Running scripts is disabled on this system"
Run this once before the script:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

### GitHub API rate limit
If downloads fail with a 403, you've hit the GitHub API limit. Wait an hour and re-run the script — it skips files already downloaded.

### A mod's setup-*.exe is missing
Some mods distribute their setup file separately from the data folder. Check the extracted folder — you may need to copy `setup-modname.exe` manually to the game directory.

### WeiDU installer crashes immediately
Likely a path issue. Make sure your game path doesn't contain unusual characters. If it does, you may need to copy the modded folder to a path without spaces (e.g., `C:\BG2EE\`).

### A mod installed but I don't see its content
Check `WeiDU.log` — if the mod isn't listed, it didn't install. Re-run its `setup-*.exe` manually.

### Steam "verifies" and removes my mods
**Don't use Steam's "Verify integrity of game files"** on a modded install. Launch the game directly via `Baldur.exe`. If you must verify, do it on a clean backup copy.

### The script says "manual downloads required" but I already have the files
Drop the files into `D:\BG2_ModStaging\downloads\` before running the script. It'll detect existing files and skip re-downloading.

### Script can't find a mod folder after extraction
Some mods have nested folders (e.g., `spell_rev/spell_rev/...`). The script searches recursively, but if it fails, manually copy the innermost mod folder to the game directory.

---

## After Installation — Distributing to LAN Players

This script handles YOUR install. For the other 3-5 players:

**Recommended**: Copy your entire modded game folder to each player's machine. This guarantees identical installs.

```powershell
# Example: copy to a network share or external drive
$source = "D:\SteamLibrary\steamapps\common\Baldur's Gate II Enhanced Edition"
$dest   = "\\OTHER-PC\BG2EE-Modded"   # or "E:\BG2EE-Modded" for USB
Copy-Item -Path $source -Destination $dest -Recurse -Force
```

Each player then:
1. Verifies their `WeiDU.log` matches yours (open it in Notepad, compare line counts and mod names)
2. Launches `Baldur.exe` directly (NOT via Steam)
3. Joins your LAN game via Direct IP

See the main plan (`bg2ee-mods.md`) for the full multiplayer setup walkthrough.

---

## Script Summary

- **Total mods**: 12
- **Auto-downloaded from GitHub**: 9
- **Manual download required**: 3 (Artisan's Kitpack, Bardic Wonders, Item Pack)
- **Interactive component selection**: All (safer than guessing component numbers)
- **Estimated time**: 30-60 minutes depending on download speeds

If anything in the script doesn't work as expected, note which phase failed and check the Troubleshooting section above.
