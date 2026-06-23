@echo off
REM ==========================================
REM BG2:EE Fix-Up Install (Interactive)
REM Run from the game directory as Admin
REM Close Steam and BG2:EE first!
REM ==========================================

cd /d "D:\SteamLibrary\steamapps\common\Baldur's Gate II Enhanced Edition"

echo ==================================================
echo  BG2:EE Fix-Up Install (ALL Interactive)
echo ==================================================
echo.
echo TIP: Each installer shows a numbered list.
echo      Type a NUMBER to select, then press ENTER
echo      on empty line to install selected items.
echo      Already-installed items show [I].
echo.
pause

echo.
echo ==================================================
echo  1/10 Item Revisions (NOT installed yet)
echo ==================================================
echo  ACTION: Install the MAIN component (#0 or first item)
echo.
pause
setup-item_rev.exe --noautoupdate --use-lang en_US --language 0

echo.
echo ==================================================
echo  2/10 Spell Revisions (add missing components)
echo ==================================================
echo  Currently: only main component installed.
echo  ACTION: Select ALL remaining components (1-7)
echo  These are optional spell fixes/improvements.
echo.
pause
setup-spell_rev.exe --noautoupdate --use-lang en_US --language 0

echo.
echo ==================================================
echo  3/10 IWDification (FIX: add spell packs)
echo ==================================================
echo  Currently: wrong components installed (cosmetic).
echo  ACTION: Find "Arcane Spell Pack" and "Divine Spell Pack"
echo          and install them. These add 70+ new spells.
echo.
pause
setup-iwdification.exe --noautoupdate --use-lang en_US --language 0

echo.
echo ==================================================
echo  4/10 Artisan Kitpack (add missing kits)
echo ==================================================
echo  Currently: only 2 components installed.
echo  ACTION: Select ALL kits (fighter, ranger, paladin, 
echo          druid, thief, monk overhauls + new kits).
echo  Skip anything you don't want, but get the kits!
echo.
pause
Setup-ArtisansKitpack.exe --noautoupdate --use-lang en_US --language 0

echo.
echo ==================================================
echo  5/10 Bardic Wonders (NOT installed yet)
echo ==================================================
echo  ACTION: Install ALL bard kits.
echo.
pause
Setup-BardicWonders.exe --noautoupdate --use-lang en_US --language 0

echo.
echo ==================================================
echo  6/10 Talents of Faerun (via weidu.exe)
echo ==================================================
echo  ACTION: Install Class/Kit Revisions + Multiclass Kits
echo           + New Kits.
echo  SKIP: Favored Soul, Deity/Sphere system, HLA overhaul.
echo.
pause
weidu.exe dw_talents/dw_talents.tp2 --noautoupdate --use-lang en_US --language 0

echo.
echo ==================================================
echo  7/10 Ascension (NOT installed yet)
echo ==================================================
echo  ACTION: Install core story components:
echo    - The Ascension (rewritten ToB finale)
echo    - Redeemable Balthazar
echo    - Restored Bhaalspawn Powers
echo    - Improved Sarevok/Imoen dialogues
echo  SKIP: Tougher Enemies (keeps Core Rules difficulty)
echo.
pause
setup-ascension.exe --noautoupdate --use-lang en_US --language 0

echo.
echo ==================================================
echo  8/10 Wheels of Prophecy (via weidu.exe)
echo ==================================================
echo  ACTION: Install the main component (non-linear ToB).
echo.
pause
weidu.exe wheels_of_prophecy/setup-wheels.tp2 --noautoupdate --use-lang en_US --language 0

echo.
echo ==================================================
echo  9/10 Item Pack (via weidu.exe)
echo ==================================================
echo  ACTION: Install the main component (45 new items).
echo.
pause
weidu.exe ItemPack/ItemPack.tp2 --noautoupdate --use-lang en_US --language 0

echo.
echo ==================================================
echo  10/10 Tweaks Anthology (QOL only)
echo ==================================================
echo  ACTION: Select ONLY quality-of-life components:
echo    - Remove Helmet Animations
echo    - Increase Ammo/Gem/Potion Stacking
echo    - Stackable Rings/Amulets
echo    - Restore BG2 Spells + Make Scrolls Available
echo    - Un-Nerfed Sorcerer Spell Progression
echo    - Alter Multi/Dual-Class Restrictions
echo  SKIP: Harder, Difficult, Deadlier, Max HP, nerfing
echo.
pause
setup-cdtweaks.exe --noautoupdate --use-lang en_US --language 0

echo.
echo ==================================================
echo  DONE! Check your WeiDU.log:
echo ==================================================
findstr "^~" WeiDU.log
echo.
echo Total components:
findstr /r /c "^~" WeiDU.log | find /v /c ""
echo.
pause
