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
        Repo="Gibberlings3/BG2-Fixpack"
        AssetPattern="bg2fixpack-.*\.exe$"
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
        AssetPattern="item_rev-.*\.exe$"
        FolderName="item_rev"
        SetupExe="setup-item_rev.exe"
        Install="interactive"
        Sort=3
        Note="Install: main component only. Skip optional rule-changing components."
    }
    @{
        Name="IWDification"
        Repo="Gibberlings3/iwdification"
        AssetPattern="iwdification-.*\.exe$"
        FolderName="iwdification"
        SetupExe="setup-iwdification.exe"
        Install="interactive"
        Sort=4
        Note="Install ONLY: 'Arcane Spell Pack' + 'Divine Spell Pack'. Skip 'Class Updates' to avoid kit conflicts."
    }
    @{
        Name="Talents of Faerun (kit/multiclass only)"
        Repo="Gibberlings3/TalentsOfFaerun"
        AssetPattern="dw_talents-.*\.exe$"
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
        FolderName="ArtisansKitpack"
        SetupExe="Setup-ArtisansKitpack.exe"
        Install="interactive"
        Sort=6
        Note="Install all components."
    }
    @{
        Name="Bardic Wonders"
        Repo=$null
        ManualUrl="https://artisans-corner.com/bardic-wonders/"
        FolderName="BardicWonders"
        SetupExe="Setup-BardicWonders.exe"
        Install="interactive"
        Sort=7
        Note="Install all components."
    }
    @{
        Name="Shadow Magic (Shadow Adept)"
        Repo=$null
        ManualUrl="https://artisans-corner.com/shadow-magic/"
        FolderName="shadowadept"
        SetupExe="setup-shadowadept.exe"
        Install="interactive"
        Sort=8
        Note="Install all components - adds the Shadow Adept class (shadow magic caster)."
    }
    @{
        Name="Warlock"
        Repo=$null
        ManualUrl="https://artisans-corner.com/warlock/"
        FolderName="Artisans_Warlock"
        SetupExe="Setup-Artisans_Warlock.exe"
        Install="interactive"
        Sort=9
        Note="Install all components - adds the Warlock class (pact magic, eldritch blast)."
    }
    @{
        Name="Ascension"
        Repo="Gibberlings3/Ascension"
        AssetPattern="ascension-.*\.zip$"
        FolderName="ascension"
        SetupExe="setup-ascension.exe"
        Install="interactive"
        Sort=10
        Note="Install: 'The Ascension' core + 'Redeemable Balthazar' + 'Restored Bhaalspawn Powers'. SKIP 'Tougher Enemies' (Core Rules)."
    }
    @{
        Name="Wheels of Prophecy"
        Repo="Gibberlings3/WheelsOfProphecy"
        AssetPattern="wheels-.*\.exe$"
        FolderName="wheels_of_prophecy"
        SetupExe="setup-wheels_of_prophecy.exe"
        Install="interactive"
        Sort=11
        Note="Install: main/only component."
    }
    @{
        Name="Unfinished Business"
        Repo="Pocket-Plane-Group/UnfinishedBusiness"
        AssetPattern="ub-.*\.zip$|UnfinishedBusiness.*\.zip$"
        FolderName="ub"
        SetupExe="setup-ub.exe"
        Install="interactive"
        Sort=12
        Note="Install: Quest Restorations + Item Restorations + Dialogue Restorations. SKIP NPC Portrait Restorations (cosmetic)."
    }
    @{
        Name="Item Pack"
        Repo="Dau1makan/Item-Pack"
        AssetPattern="Item_Pack.*\.zip$"
        ManualUrl="https://github.com/Dau1makan/Item-Pack/releases"
        FolderName="ItemPack"
        SetupExe="setup-ItemPack.exe"
        Install="interactive"
        Sort=13
        Note="Install: main component (45 new items)."
    }
    @{
        Name="The Tweaks Anthology"
        Repo="Gibberlings3/Tweaks-Anthology"
        AssetPattern="cdtweaks-.*\.exe$"
        FolderName="cdtweaks"
        SetupExe="setup-cdtweaks.exe"
        Install="interactive"
        Sort=14
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

    # Self-extracting .exe (like cdtweaks, wheels, iwdification, etc.)
    # Match by checking if any .exe in downloads contains key parts of the mod name
    $searchTerms = @($mod.FolderName, ($mod.FolderName -replace "_",""), ($mod.SetupExe -replace "setup-","" -replace "\.exe$",""))
    $selfExtractExe = $null
    $allExes = Get-ChildItem -Path $downloadsPath -File -Filter "*.exe" -ErrorAction SilentlyContinue
    foreach ($exe in $allExes) {
        foreach ($term in $searchTerms) {
            if ($exe.Name -match $term) {
                $selfExtractExe = $exe
                break
            }
        }
        if ($selfExtractExe) { break }
    }
    if (-not $foundFolder -and $selfExtractExe) {
        Write-OK "Self-extracting installer: $($selfExtractExe.Name) -> game folder"
        Copy-Item -Path $selfExtractExe.FullName -Destination $Config.GamePath -Force
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

    # Try to find the setup executable - check for exact name first, then pattern match
    $setupPath = Join-Path $Config.GamePath $mod.SetupExe
    if (-not (Test-Path $setupPath)) {
        # Look for any .exe that matches the mod name pattern (self-extracting installers)
        $searchTerms = @($mod.FolderName, ($mod.FolderName -replace "_",""), ($mod.SetupExe -replace "setup-","" -replace "\.exe$",""))
        $foundExe = $null
        $allExes = Get-ChildItem -Path $Config.GamePath -File -Filter "*.exe" -ErrorAction SilentlyContinue
        foreach ($exe in $allExes) {
            foreach ($term in $searchTerms) {
                if ($exe.Name -match $term -and $exe.Name -notmatch "^setup-") {
                    $foundExe = $exe
                    break
                }
            }
            if ($foundExe) { break }
        }
        if ($foundExe) {
            $setupPath = $foundExe.FullName
        } else {
            Write-Err2 "Setup executable not found: $($mod.SetupExe)"
            Write-Host "    Looking for .exe matching: $($mod.FolderName)"
            Write-Host "    Files in game dir matching pattern:"
            Get-ChildItem -Path $Config.GamePath -File -Filter "*.exe" | Where-Object { $_.Name -match ($mod.FolderName -replace "_",".") } | ForEach-Object { Write-Host "      $($_.Name)" }
            continue
        }
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