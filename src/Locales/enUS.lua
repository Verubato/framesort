local _, addon = ...
local L = addon.Locale

-- # Main Options screen #
-- used in FrameSort - 1.2.3 version header, %s is the version number
L["FrameSort - %s"] = nil
L["There are some issuse that may prevent FrameSort from working correctly."] = nil
L["Please go to the Health Check panel to view more details."] = nil
L["Role/spec"] = nil
L["Group"] = nil
L["Alphabetical"] = nil
L["Arena - 2v2"] = nil
L["Arena - 3v3"] = nil
L["Arena - 3v3 & 5v5"] = nil
L["Enemy Arena (see addons panel for supported addons)"] = nil
L["Dungeon (mythics, 5-mans, delves)"] = nil
L["Raid (battlegrounds, raids)"] = nil
L["World (non-instance groups)"] = nil
L["Player"] = nil
L["Sort"] = nil
L["Top"] = nil
L["Middle"] = nil
L["Bottom"] = nil
L["Hidden"] = nil
L["Group"] = nil
L["Reverse"] = nil

-- # Sorting Method screen #
L["Sorting Method"] = nil
L["Secure"] = nil
L["SortingMethod_Secure_Description"] = [[
Adjusts the position of each individual frame and doesn't bug/lock/taint the UI.
\n
Pros:
 - Can sort frames from other addons.
 - Can apply frame spacing.
 - No taint (technical term for addons interfering with Blizzard's UI code).
\n
Cons:
 - Fragile house of cards situation to workaround Blizzard spaghetti.
 - May break with WoW patches and cause the developer to go insane.
]]
L["Traditional"] = nil
L["SortingMethod_Secure_Traditional"] = [[
This is the standard sorting mode that addons and macros have used for 10+ years.
It replaces the internal Blizzard sorting method with our own.
This is the same as the 'SetFlowSortFunction' script but with FrameSort configuration.
\n
Pros:
 - More stable/reliable as it leverages Blizzard's internal sorting methods."] = nil
\n
Cons:
 - Only sorts Blizzard party frames, nothing else.
 - Will cause Lua errors which is normal and can be ignored.
 - Cannot apply frame spacing.
]]
L["Please reload after changing these settings."] = nil
L["Reload"] = nil

-- # Ordering screen #
L["Ordering"] = nil
L["Specify the ordering you wish to use when sorting by role."] = nil
L["Tanks"] = nil
L["Healers"] = nil
L["Casters"] = nil
L["Hunters"] = nil
L["Melee"] = nil

-- # Auto Leader screen #
L["Auto Leader"] = nil
L["Auto promote healers to leader in solo shuffle."] = nil
L["Why? So healers can configure target marker icons and re-order party1/2 to their preference."] = nil
L["Enabled"] = nil

-- # Blizzard Keybindings screen (FrameSort's section) #
L["Targeting"] = nil
L["Target frame 1 (top frame)"] = nil
L["Target frame 2"] = nil
L["Target frame 3"] = nil
L["Target frame 4"] = nil
L["Target frame 5"] = nil
L["Target bottom frame"] = nil
L["Target frame 1's pet"] = nil
L["Target frame 2's pet"] = nil
L["Target frame 3's pet"] = nil
L["Target frame 4's pet"] = nil
L["Target frame 5's pet"] = nil
L["Target enemy frame 1"] = nil
L["Target enemy frame 2"] = nil
L["Target enemy frame 3"] = nil
L["Target enemy frame 1's pet"] = nil
L["Target enemy frame 2's pet"] = nil
L["Target enemy frame 3's pet"] = nil
L["Focus enemy frame 1"] = nil
L["Focus enemy frame 2"] = nil
L["Focus enemy frame 3"] = nil
L["Cycle to the next frame"] = nil
L["Cycle to the previous frame"] = nil
L["Target the next frame"] = nil
L["Target the previous frame"] = nil

-- # Keybindings screen #
L["Keybindings"] = nil
L["Keybindings_Description"] = [[
You can find the FrameSort keybindings in the standard WoW keybindings area.
\n
What are the keybindings useful for?
They are useful for targeting players by their visually ordered representation rather than their
party position (party1/2/3/etc.)
\n
For example, imagine a 5-man dungeon group sorted by role that looks like the following:
  - Tank, party3
  - Healer, player
  - DPS, party1
  - DPS, party4
  - DPS, party2
\n
As you can see their visual representation differs to their actual party position which
makes targeting confusing.
If you were to /target party1, it would target the DPS player in position 3 rather than the tank.
\n
FrameSort keybindings will target based on their visual frame position rather than party number.
So targeting 'Frame 1' will target the Tank, 'Frame 2' the healer, 'Frame 3' the DPS in spot 3, and so on.
]]

-- # Macros screen # --
L["Macros"] = nil
-- "|4macro:macros;" is a special command to pluralise the word "macro" to "macros" when %d is greater than 1
L["FrameSort has found %d|4macro:macros; to manage."] = nil
L['FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.'] = nil
L["Below are some examples on how to use this."] = nil

L["Macro_Example1"] = [[#showtooltip
#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][@healer,exists] Blessing of Sanctuary]]

L["Macro_Example2"] = [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] Dispel]]

L["Macro_Example3"] = [[#FrameSort EnemyHealer, EnemyHealer
/cast [@doesntmatter] Shadowstep;
/cast [@placeholder] Kick;]]

-- %d is the number for example 1/2/3
L["Example %d"] = nil
L["Supported variables:"] = nil
L["The first DPS that's not you."] = nil
L["Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS."] = nil
L["Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work."] = nil
L["Need to save on macro characters? Use abbreviations to shorten them:"] = nil
L['Use "X" to tell FrameSort to ignore an @unit selector:'] = nil
L["Skip_Example"] = [[
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] Spell;]]

-- # Spacing screen #
L["Spacing"] = nil
L["Add some spacing between party/raid frames."] = nil
L["This only applies to Blizzard frames."] = nil
L["Party"] = nil
L["Raid"] = nil
L["Group"] = nil
L["Horizontal"] = nil
L["Vertical"] = nil

-- # Addons screen #
L["Addons"] = nil
L["Addons_Supported_Description"] = [[
FrameSort supports the following:
\n
Blizzard
 - Party: yes
 - Raid: yes
 - Arena: yes
\n
ElvUI
 - Party: yes
 - Raid: no
 - Arena: no
\n
sArena
 - Arena: yes
\n
Gladius
 - Arena: yes
 - Bicmex version: yes
\n
GladiusEx
 - Party: yes
 - Arena: yes
\n
Cell
 - Party: yes
 - Raid: yes, only when using combined groups.
\n
Shadowed Unit Frames
 - Party: yes
 - Arena: yes
\n
Grid2
 - Party/raid: yes
\n
]]

-- # Api screen #
L["Api"] = nil
L["Want to integrate FrameSort into your addons, scripts, and Weak Auras?"] = nil
L["Here are some examples."] = nil
L["Retrieved an ordered array of party/raid unit tokens."] = nil
L["Retrieved an ordered array of arena unit tokens."] = nil
L["Register a callback function to run after FrameSort sorts frames."] = nil
L["Retrieve an ordered array of party frames."] = nil
L["Change a FrameSort setting."] = nil
L["View a full listing of all API methods on GitHub."] = nil

-- # Help screen #
L["Help"] = nil
L["Discord"] = nil
L["Need help with something?"] = nil
L["Talk directly with the developer on Discord."] = nil

-- # Health Check screen -- #
L["Health Check"] = nil
L["Try this"] = nil
L["Any known issues with configuration or conflicting addons will be shown below."] = nil
L["N/A"] = nil
L["Passed!"] = nil
L["Failed"] = nil
L["(unknown)"] = nil
L["(user macro)"] = nil
L["Using grouped layout for Cell raid frames"] = nil
L["Please check the 'Combined Groups (Raid)' option in Cell -> Layouts"] = nil
L["Can detect frames"] = nil
L["FrameSort currently supports frames from these addons: %s"] = nil
L["Using Raid-Style Party Frames"] = nil
L["Please enable 'Use Raid-Style Party Frames' in the Blizzard settings"] = nil
L["Keep Groups Together setting disabled"] = nil
L["Change the raid display mode to one of the 'Combined Groups' options via Edit Mode"] = nil
L["Disable the 'Keep Groups Together' raid profile setting."] = nil
L["Only using Blizzard frames with Traditional mode"] = nil
L["Traditional mode can't sort your other frame addons: '%s'"] = nil
L["Using Secure sorting mode when spacing is being used."] = nil
L["Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method"] = nil
L["Blizzard sorting functions not tampered with"] = nil
L['"%s" may cause conflicts, consider disabling it'] = nil
L["No conflicting addons"] = nil
L["Main tank and assist setting disabled"] = nil
L["Please disable the 'Display Main Tank and Assist' option in Options -> Interface -> Raid Frames"] = nil
