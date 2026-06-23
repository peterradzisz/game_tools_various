@echo off
REM ==========================================
REM BG2:EE Clean Install - All 14 Mods
REM Run from the game directory
REM Make sure Steam and BG2:EE are CLOSED
REM ==========================================

cd /d "D:\SteamLibrary\steamapps\common\Baldur's Gate II Enhanced Edition"

echo ========================================
echo  BG2:EE Clean Install (All 14 Mods)
echo ========================================
echo.
echo Make sure Steam and BG2:EE are CLOSED.
echo Do NOT launch the game during installation.
echo.
pause

echo.
echo ^>^>^> 1/14 BG2 Fixpack (skips on EE - normal)
setup-bg2fixpack.exe --noautoupdate --use-lang en_US --language 0 --force-install 0

echo.
echo ^>^>^> 2/14 Spell Revisions (5+ min, be patient!)
setup-spell_rev.exe --noautoupdate --use-lang en_US --language 0 --force-install-list 0 1 2 3 4 5 6 7

echo.
echo ^>^>^> 3/14 Item Revisions
setup-item_rev.exe --noautoupdate --use-lang en_US --language 0 --force-install 0

echo.
echo ^>^>^> 4/14 IWDification (Arcane + Divine spells)
setup-iwdification.exe --noautoupdate --use-lang en_US --language 0 --force-install-list 10 20

echo.
echo ^>^>^> 5/14 Artisan's Kitpack (all kits)
Setup-ArtisansKitpack.exe --noautoupdate --use-lang en_US --language 0 --force-install-list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58

echo.
echo ^>^>^> 6/14 Bardic Wonders (all bard kits)
Setup-BardicWonders.exe --noautoupdate --use-lang en_US --language 0 --force-install-list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25

echo.
echo ^>^>^> 7/14 Shadow Magic
setup-shadowadept.exe --noautoupdate --use-lang en_US --language 0 --force-install-list 0 4 5 8

echo.
echo ^>^>^> 8/14 Warlock
Setup-Artisans_Warlock.exe --noautoupdate --use-lang en_US --language 0 --force-install 0

echo.
echo ========================================
echo  9/14 Talents of Faerun (INTERACTIVE)
echo ========================================
echo  GUIDANCE:
echo    INSTALL: Class/Kit Revisions, Multiclass Kits, New Kits
echo    SKIP: Favored Soul, Deity/Sphere system, HLA overhaul
echo.
pause
start /wait setup-dw_talents.exe

echo.
echo ^>^>^> 10/14 Ascension (story, skip tougher enemies)
setup-ascension.exe --noautoupdate --use-lang en_US --language 0 --force-install-list 0 10 20 30 40 50 60

echo.
echo ^>^>^> 11/14 Wheels of Prophecy
setup-wheels_of_prophecy.exe --noautoupdate --use-lang en_US --language 0 --force-install 0

echo.
echo ^>^>^> 12/14 Unfinished Business (all)
setup-ub.exe --noautoupdate --use-lang en_US --language 0 --force-install-list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25

echo.
echo ^>^>^> 13/14 Item Pack
Setup-ItemPack.exe --noautoupdate --use-lang en_US --language 0 --force-install 0

echo.
echo ========================================
echo  14/14 Tweaks Anthology (INTERACTIVE)
echo ========================================
echo  GUIDANCE - Select ONLY:
echo    Remove Helmet Animations
echo    Increase Ammo/Gem/Potion Stacking
echo    Stackable Rings/Amulets
echo    Restore BG2 Spells
echo    Un-Nerfed Sorcerer Progression
echo    Alter Multi/Dual-Class Restrictions
echo  SKIP: Harder/Difficult/Deadlier/Max HP
echo.
pause
start /wait setup-cdtweaks.exe

echo.
echo ========================================
echo  Installation Complete!
echo ========================================
echo.
echo Installed mods:
findstr "^~" WeiDU.log | findstr /v "^//" | find /v /c ""
echo components total
echo.
echo Launch Baldur.exe directly (NOT via Steam).
pause
