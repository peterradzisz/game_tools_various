@echo off
REM ==========================================
REM Install Tweaks Anthology (QOL only)
REM Run from game dir as Admin
REM ==========================================

cd /d "D:\SteamLibrary\steamapps\common\Baldur's Gate II Enhanced Edition"

echo ==================================================
echo  Tweaks Anthology - QOL Component Installer
echo ==================================================
echo.
echo SELECT ONLY these QOL components (type number + Enter):
echo.
echo   - Remove Helmet Animations
echo   - Increase Ammo Stacking (pick max)
echo   - Increase Gem and Jewelry Stacking
echo   - Increase Potion Stacking
echo   - Stackable Rings, Amulets, etc.
echo   - Restore (Most) BG2 Spells and Make Scrolls Available
echo   - Un-Nerfed Sorcerer Spell Progression Table
echo   - Alter Multi-Class Restrictions
echo   - Alter Dual-Class Restrictions
echo.
echo SKIP anything saying:
echo   Harder, Difficult, Deadlier, Max HP, or nerfing
echo.
echo TIP: Type a number to select, press Enter on empty
echo      line to install. Type Q to quit without installing.
echo.
pause

setup-cdtweaks.exe --noautoupdate --use-lang en_US --language 0

echo.
echo Done! Check WeiDU.log:
findstr "cdtweaks" WeiDU.log
echo.
pause
