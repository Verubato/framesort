# Changelog

## 7.18.2

12.1 version support

## 7.18.1

Hide player forbidden frame guard.

## 7.18.0

Updated minimum spacing from 0 to -1.

## 7.17.2

Fixed edit mode hanging when the hide player module is enabled.

## 7.17.1

Bumped TOC to 12.0.7.

## 7.17.0

- Added ElvUI arena frames support (untested).
- Fixed Blizzard party frame borders after sorting.

## 7.16.3

Better hide player implementation to help prevent the player raid frame from re-showing.

## 7.15.2

Fixed UnitGUID throwing errors in Midnight from the inspector module.

## 7.15.1

Fix for ElvUI frames not sorting when zoning into arena.

## 7.15.0

More performance improvements.

## 7.14.3

Minor performance improvement.

## 7.14.2

Another regression bug fix from previous release, sorry.

## 7.14.1

Regression bug fix from previous release.

## 7.14.0

- Added option to enable/disable logging (disabled by default).
- Some minor performance improvements.

## 7.13.5

Secret value handling fix when sorting external frame addons.

## 7.13.4

12.0.5 TOC support.

## 7.13.3

Fixed secret value error happening at the end of each solo shuffle round.

## 7.13.2

Fix for bizarre taint issue when running ElvUI + sArena + FrameSort in combination.

## 7.13.1

Fixed tooltips sometimes disappearing in player inspections after a few seconds.

## 7.13.0

Removed enemy nameplate support on 12.0.1 as it's no longer possible.

## 7.12.1

Fixed minor issue with restoring nameplate names for both friendly and enemy nameplates when only one of those options are disabled.

## 7.12.0

Added Platynator support for nameplate numbering.

## 7.11.2

Enemy nameplate frame number fix.

## 7.11.1

Fixed errors happening when BattleGroundEnemies and Gladius are enabled but haven't loaded properly.

## 7.11.0

Added support for classic style non-compact party frames.

## 7.10.0

Fixed arena123 not resolving since Midnight for external addons such as MiniMarkers and ArenaCore.

## 7.9.5

Added support for the new DH Devourer spec.

## 7.9.4

Fixed issue with resolving arena pet nameplate units.

## 7.9.3

Grid2 - better logic for filtering out benched players for mythic raids.

## 7.9.2

- Added cycle friendly dps keybinding.
- Potential fix for Grid2 units disappearing in dungeons.

## 7.9.1

- Potential fix for Blizzard enemy pet frames being pushed too far down.
- Added API method to clear spec cache.

## 7.9.0

Faster spec detection.

## 7.8.2

Spec detection fix for external addons (MiniMarkers).

## 7.8.1

- Unit inspection performance improvements.
- Added new API method for external addons such as MiniMarkers to use.

## 7.8.0

- Added feature to manually change the language.
- Added API method to get the unit for a FrameSort variable.
- Fixed dropdowns not using the modern UI style (retail).

## 7.7.6

Fixed ElvUI only showing the player frame sometimes.

## 7.7.5

Fixed regression bug causing enemy units to sometimes not sort properly.

## 7.7.4

Fixed regression bug with the cycle roles feature (API command).

## 7.7.3

Fix for very rare and weird bug (Blizzard shenanigans) happening in solo shuffle where frames become unsorted during combat.

## 7.7.2

Potential caching issue bug fix.

## 7.7.1

Fixed attempting to retrieve spec information for pets and target frames causing log warning spam.

## 7.7.0

Added new feature to sort player at the top of the respective role.

## 7.6.3

Fixed issue from previous release with Grid2, Cell, and ElvUI causing it to only show 1 frame inside raids.

## 7.6.2

Better main tank and assist raid frames handling.

