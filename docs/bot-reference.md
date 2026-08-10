# FrameSort Reference

Reference for answering questions about the FrameSort addon: its features, settings,
keybindings, supported addons, API, and macro system.
Everything here is derived from the FrameSort source code. Part 1 covers the addon
itself. Part 2 and Part 3 cover the macro system and are the authority for writing
and reviewing FrameSort macros (derived from `src/Modules/Macro/Parser.lua` and its tests).

---

# Part 1 - The addon

## 1. What FrameSort does

FrameSort sorts party, raid, and arena unit frames and puts the player's own frame
where they want it (top, middle, bottom, or hidden). Around that core it provides:

- Sorting for Blizzard frames and several popular frame addons (ElvUI, Cell, Grid2,
  Shadowed Unit Frames, sArena, Gladius, GladiusEx, Gladdy, BattleGroundEnemies).
- Enemy arena frame sorting.
- Keybindings that target players by their visual frame position instead of their
  party number.
- Macro variables (`@Healer`, `@EnemyHealer`, `@Frame1`, ...) via the `#FrameSort`
  macro header.
- Spacing between frames.
- Nameplate text replacement (frame number, name, spec).
- Auto-promoting the healer to leader in solo shuffle.
- A public API for other addons, scripts, and WeakAuras.

## 2. Environment facts

| Fact | Value |
| --- | --- |
| Addon version | 7.18.4 |
| Author | Verz |
| Interface versions (TOC) | 120100, 120007, 50504, 40402, 38002, 38001, 30405, 30300, 20506, 11509 (retail, MoP classic, Cata classic, wrath, TBC, and classic era clients) |
| Saved variables | `FrameSortDB` |
| Slash commands | `/fs` and `/framesort` - both open the FrameSort options panel |
| Options location | WoW Settings -> AddOns -> FrameSort (a category with sub-panels) |
| Languages | Auto (follows the client) plus English, Deutsch, Espanol, Espanol (Mexico), Francais, Italiano, Korean, Portugues (Brasil), Russian, Simplified Chinese, Traditional Chinese |
| Install sources | CurseForge, Wago.io, WowUp, GitHub releases |
| Support | Discord (link shown on the addon's Discord panel), GitHub issues at github.com/Verubato/framesort |

Note: on the Midnight expansion (12.x) and later, the options panel cannot be opened
during combat; `/fs` prints a "can't do that during combat" style notification instead.

## 3. Sorting

### 3.1 Areas

Sorting is configured separately per area on the main FrameSort panel. Each area has
its own Enabled checkbox and its own settings. The area used is decided by the
instance you are in:

| Options panel section | When it applies | Default state |
| --- | --- | --- |
| Arena - 2v2 | Arena instances when your group has exactly 2 members | Enabled |
| Arena - 3v3 (labelled "Arena - 3v3 & 5v5" on TBC clients) | All other arena sizes | Enabled |
| Enemy Arena (see addons panel for supported addons) | Enemy frames, arena instances only | Disabled |
| Dungeon (mythics, 5-mans, delves) | Instance type "party" or "scenario" (delves are scenarios) | Enabled |
| Raid (battlegrounds, raids) | Instance type "raid" or "pvp" (battlegrounds) | Enabled state: Disabled |
| World (non-instance groups) | Everywhere else (open world groups) | Enabled |

The Arena sections only appear on clients that have arena (TBC+). The Enemy Arena
section only appears on clients with enemy spec support (MoP+).

Important consequences:

- Raid sorting is off by default. Battlegrounds count as the Raid area.
- Enemy arena sorting is off by default.
- Solo shuffle is an arena, so the Arena - 3v3 settings apply to friendly frames there.

### 3.2 Player position

Each friendly area has a "Player" row of checkboxes: Top, Middle, Bottom, Hidden.
Default is Top for every area.

- Top: your frame is first.
- Middle: your frame is placed at the midpoint of the group (pets ignored when
  computing the midpoint).
- Bottom: your frame is last.
- Hidden: your frame is removed from the frames entirely. Hiding only works on
  Blizzard frames; FrameSort hides the Blizzard party/raid frame for your unit and
  re-hides it when Blizzard re-shows it (deferred to after combat if needed).
- Unchecking all four boxes means no special player positioning; you are sorted like
  everyone else.

The Enemy Arena section has no Player row.

### 3.3 Group sort mode

Each area has a "Sort" row: Group, Spec (labelled "Role" on clients without spec
inspection), Alphabetical, and a separate Reverse checkbox. Exactly one mode can be
checked. Defaults: Group for Arena and World, Spec/Role for Dungeon and Raid,
Group for Enemy Arena.

- Group: orders by unit number (party1 < party2 < ... / raid1 < raid2 < ...), i.e.
  Blizzard's natural group order.
- Spec (Role): orders by role and spec. The comparison chain is:
  1. Units with an assigned role come before units without one.
  2. Role/class-type order, using the positions from the Ordering panel
     (Tanks/Healers/Casters/Hunters/Melee).
  3. Spec order within the type, using the Spec Priority panel's order.
  4. Class id as a tiebreaker.
  5. Group order as the final tiebreaker.
- Alphabetical: orders by character name.
- Reverse: reverses the group ordering. Player positioning (Top/Middle/Bottom) is
  applied on top of the reversed order.
- In every mode, players come before pets; pets are ordered by their owner's order.

Spec sorting depends on spec data that FrameSort queries from the server (roughly
1-2 seconds per player), so right after joining a group the order can take a short
while to settle. Roles come from the game's role assignments; where a client has no
role system, role-based ordering falls back to class type.

### 3.4 Enemy arena sorting

The Enemy Arena section sorts enemy arena frames (Blizzard's arena frames or a
supported arena addon; see section 7). It has Group and Spec/Role modes plus Reverse,
no Alphabetical, and no Player row. It only operates inside arena instances. Enemy
roles come from arena opponent spec information, which requires a MoP+ client and may
be briefly unavailable at the start of a match.

### 3.5 The Ordering panel

Panel: FrameSort -> Ordering. "Specify the ordering you wish to use when sorting by
spec." Five dropdowns assign a position 1-5 to each type; choosing a taken number
swaps positions with the type that had it.

| Type | Default position |
| --- | --- |
| Tanks | 1 |
| Healers | 2 |
| Casters | 3 |
| Hunters | 4 |
| Melee | 5 |

### 3.6 The Spec Priority panel

Panel: FrameSort -> Spec Priority (only present on clients with spec inspection).
Pick a spec type (Tank, Healer, Hunter, Caster, Melee) from a dropdown, then drag and
drop specs to set their order within that type. "Reset this type" restores the
default order for the selected type. The panel notes that spec information is queried
from the server and takes 1-2 seconds per player, so accurate sorting can lag
slightly behind joining a group.

## 4. Sorting method (Secure vs Traditional)

Panel: FrameSort -> Sorting Method. Two mutually exclusive checkboxes. Default:
Secure. A reload is required after changing this setting (the panel shows a reminder
and a Reload button).

Secure (default) - repositions each individual frame without tainting the UI:

- Pros: can sort frames from other addons; can apply frame spacing; no taint.
- Cons: a fragile workaround of Blizzard internals; may break with WoW patches.

Traditional - the classic approach used by sorting addons and macros for 10+ years;
replaces Blizzard's internal sorting function (equivalent to the
`SetFlowSortFunction` script, but driven by FrameSort configuration):

- Pros: more stable/reliable, leverages Blizzard's internal sorting.
- Cons: only sorts Blizzard party frames, nothing else; will cause Lua errors which
  are normal and can be ignored; cannot apply frame spacing.

Traditional mode also requires the raid frames to not use "Keep Groups Together"
(retail: the raid display mode must be one of the "Combined Groups" options in Edit
Mode). The Health Check panel flags this.

## 5. When sorting runs

FrameSort re-sorts in response to group changes (roster updates, role changes, spec
changes, pets), after loading screens, when a provider addon moves its frames, and
when settings change. Sorting, targeting updates, macro rewrites, and nameplate
updates never run during combat; they are deferred until combat ends. If a sort is
pending when combat starts, FrameSort attempts one final sort just before lockdown.

## 6. Keybindings

FrameSort's keybindings are set in the standard WoW Key Bindings UI, under
FrameSort's "Targeting" section. There is no default key for any of them.

Purpose: target players by their visually ordered frame position rather than their
party number. Example: in a role-sorted dungeon group the tank might be party3;
`/target party1` would hit whoever party1 happens to be, but "Target frame 1" always
hits the top frame (the tank).

| Binding | Effect |
| --- | --- |
| Target frame 1 (top frame) ... Target frame 5 | Target the Nth friendly frame in visual order |
| Target frame 1's pet ... Target frame 5's pet | Target the pet of the Nth friendly frame |
| Target bottom frame | Target the last friendly frame |
| Target 1/2/3/4 frame(s) above bottom | Target the Nth frame counting up from the bottom |
| Target enemy frame 1/2/3 | Target the Nth enemy arena frame |
| Target enemy frame 1/2/3's pet | Target that enemy's pet |
| Focus enemy frame 1/2/3 | Set focus to the Nth enemy arena frame |
| Target the next / previous frame | Step down/up through friendly frames (stops at the ends) |
| Cycle to the next / previous frame | Step through friendly frames, wrapping around |
| Cycle to the next / previous dps | Step through friendly DPS players only, wrapping around |

Details worth knowing:

- The bindings are secure click bindings on hidden buttons named `FSTarget1`-`FSTarget5`,
  `FSTargetPet1`-`FSTargetPet5`, `FSTargetBottom`, `FSTargetBottomMinus1`-`4`,
  `FSTargetEnemy1`-`3`, `FSTargetEnemyPet1`-`3`, `FSFocusEnemy1`-`3`,
  `FSTargetNextFrame`, `FSTargetPreviousFrame`, `FSCycleNextFrame`,
  `FSCyclePreviousFrame`, `FSCycleNextDpsFrame`, `FSCyclePreviousDpsFrame`.
  They can be used in macros as `/click FSTarget1` etc.
- The units behind the bindings are updated out of combat only. Mid-combat changes to
  the group or frame order are not reflected until combat ends.
- If sorting is disabled for the current area, the bindings follow the actual visual
  order of the frames instead of FrameSort's computed order.
- Pets are excluded from the frame numbering; "frame 2" means the 2nd player frame.

## 7. Supported frame addons

The Addons panel in FrameSort's settings lists exactly this (what each addon's
frames can be sorted):

- Blizzard: party, raid, arena.
- ElvUI: party, arena.
- sArena: arena.
- Gladius: arena.
- GladiusEx: party, arena.
- Cell: party, raid (only when using combined groups).
- Shadowed Unit Frames: party, arena.
- Grid2: party, raid.
- BattleGroundEnemies: party, arena.
- Gladdy: arena.
- Arena Core: 0.9.1.7+.

Notes and requirements:

- "Arena" for ElvUI, sArena, Gladius, GladiusEx, Gladdy, and BattleGroundEnemies
  means their enemy arena frames are sorted by the Enemy Arena settings.
- Cell raid sorting requires Cell's "Combined Groups (Raid)" layout option
  (Cell -> Layouts). The Health Check panel flags this when Cell is loaded without it.
- Sorting non-Blizzard addons requires the Secure sorting method. Traditional mode
  sorts Blizzard party frames only.
- Arena Core integrates through FrameSort's public API as an external frame provider
  (FrameSort asks it to sort itself); versions before 0.9.1.7 are not supported.
- The addon "SortGroup" is known to conflict with FrameSort and is flagged by the
  Health Check.
- Frame addons not on the list (e.g. VuhDo, HealBot, Plater as a unit frame source)
  are not supported for sorting.

## 8. Other features

### 8.1 Auto Leader (solo shuffle)

Panel: FrameSort -> Auto Leader. One checkbox, default enabled. The panel only exists
on clients that have solo shuffle.

"Auto promote healers to leader in solo shuffle. Why? So healers can configure target
marker icons and re-order party1/2 to their preference."

Behaviour: during the solo shuffle waiting room, if you are the group leader and not
the healer, FrameSort promotes the healer to leader. If the healer had leader and
passed it to someone else, FrameSort does not re-promote them for that round; the
tracking resets between rounds.

### 8.2 Spacing

Panel: FrameSort -> Spacing. "Add some spacing between party, raid, and arena frames.
This only applies to Blizzard frames."

| Section | Sliders | Range | Default |
| --- | --- | --- | --- |
| Party | Horizontal, Vertical | -1 to 100 | 0 |
| Raid (labelled "Group" on classic-style clients without the compact raid container) | Horizontal, Vertical | -1 to 100 | 0 |
| Enemy Arena (only on clients with Blizzard's compact arena frame) | Horizontal, Vertical | -1 to 100 | 0 |

Each slider has an edit box for typing an exact value. Spacing requires the Secure
sorting method; Traditional mode cannot apply spacing (the Health Check flags this
combination). Spacing applies only to Blizzard frames, not to other frame addons.

### 8.3 Nameplates

Panel: FrameSort -> Nameplates. "Replace Blizzard and Platynator nameplate text with
FrameSort variables."

| Setting | Default |
| --- | --- |
| Friendly Nameplates (checkbox) | Off |
| Friendly format (text box) | `$framenumber` |
| Enemy Nameplates (checkbox) | Off |
| Enemy format (text box) | `$framenumber` |

Supported variables in the format string: `$framenumber`, `$name`, `$unit`, `$spec`
(case-insensitive). Example formats shown in the UI: `Frame - $framenumber`,
`$framenumber - $spec`, `$name - $spec`.

Only player nameplates are changed (not pets or NPCs). If Platynator is loaded,
FrameSort routes the text through Platynator's API. The Enemy Nameplates option is
hidden on client builds 12.0.1 and later because the game no longer allows addons to
resolve arena unit nameplates there.

### 8.4 Miscellaneous

Panel: FrameSort -> Miscellaneous. Currently one checkbox:

- "Player top of role" (default off): "Places you at the top of your corresponding
  role (healer/tank/dps)." Only meaningful with Spec/Role sorting; within your role
  block you are placed first. This is independent of the per-area Player position
  setting.

### 8.5 Health Check

Panel: FrameSort -> Health Check. "Any known issues with configuration or conflicting
addons will be shown below." Each check shows Passed!/Failed/N/A and a suggested fix:

| Check | What it verifies | Fix text shown |
| --- | --- | --- |
| Can detect frames | While grouped, FrameSort can see visible frames from a supported addon | Lists the supported addons |
| Keep Groups Together setting disabled | (Traditional mode only) raid frames use a combined layout | Retail: "Change the raid display mode to one of the 'Combined Groups' options via Edit Mode"; older clients: "Disable the 'Keep Groups Together' raid profile setting" |
| Only using Blizzard frames with Traditional mode | (Traditional mode only) no other frame addon is enabled | "Traditional mode can't sort your other frame addons: ..." |
| Using Secure sorting mode when spacing is being used | Spacing is only used with Secure mode | "Traditional mode can't apply spacing, consider removing spacing or using the Secure sorting method" |
| Blizzard sorting functions not tampered with | (Traditional mode only) no other addon has overwritten `CRFSort_Group`/`CRFSort_Role`/`CRFSort_Alphabetical` | Names the offending addon |
| No conflicting addons | No addon (e.g. SortGroup) is fighting over the frame containers | Names the offending addon |
| Using grouped layout for Cell raid frames | (Cell only) Cell's combined groups layout is on | "Please check the 'Combined Groups (Raid)' option in Cell -> Layouts" |

The main FrameSort panel shows a red warning pointing at the Health Check panel
whenever any applicable check fails.

### 8.6 Logging

Panel: FrameSort -> Log. "Enable Logging" checkbox (default off) plus a log viewer
and a "Copy Log" button that opens a copyable window. Useful when reporting bugs.

### 8.7 Language

Panel: FrameSort -> Language. A dropdown to pick the UI language (default Auto,
which follows the WoW client language) and a Reload button to apply it.

## 9. Public API

FrameSort exposes a global `FrameSortApi` with versioned tables: `FrameSortApi.v1`,
`.v2`, and `.v3`. v1 and v2 are kept for backwards compatibility; v3 is the current
version and, instead of throwing Lua errors on bad input, validates parameters,
logs the problem, and returns nil/false. Full listing:
https://github.com/Verubato/framesort/tree/main/src/Api

v3 methods:

- `Sorting`: `RegisterPostSortCallback(fn)`, `RegisterFrameProvider(provider)`
  (lets another addon plug its frames into FrameSort), `GetPartyFrames()`,
  `GetRaidFrames()`, `GetArenaFrames()`, `GetFrames()` (party if any, else raid),
  `GetFriendlyUnits()`, `GetEnemyUnits()` (sorted unit token arrays).
- `Options`: `GetEnabled(area)` / `SetEnabled(area, bool)`,
  `GetPlayerSortMode(area)` / `SetPlayerSortMode(area, mode)`,
  `GetGroupSortMode(area)` / `SetGroupSortMode(area, mode)`,
  `GetReverse(area)` / `SetReverse(area, bool)`,
  `GetSpacing(spacingArea)` / `SetSpacing(spacingArea, horizontal, vertical)`,
  `RegisterConfigurationChangedCallback(fn)`.
- `Inspector`: `GetUnitSpecId(unit)`, `RegisterCallback(fn)` (spec info changes),
  `PurgeCache()`.
- `Frame`: `UnitFromFrame(frame)`, `FrameNumberForUnit(unit)`,
  `CycleFriendlyRoles(roles, cycles)`, `CycleEnemyRoles(roles, cycles)`,
  `ResetFriendlyCycles()`, `ResetEnemyCycles()` (cycling is blocked in combat).
- `Caching`: `Invalidate()`.
- `Unit`: `ResolveVariable(variable)` - resolves a FrameSort macro variable (e.g.
  `"Healer"`) to a unit token.

Valid `area` values: `"Arena - 2v2"`, `"Arena - 3v3"`, `"Arena - 5v5"`,
`"Arena - Default"`, `"EnemyArena"`, `"Dungeon"`, `"Raid"`, `"World"`.
`"Arena - 3v3"`, `"Arena - 5v5"`, and `"Arena - Default"` are the same settings
table. Valid spacing areas: `"Party"`, `"Raid"`, `"EnemyArena"`. Valid player sort
modes: `"Top"`, `"Middle"`, `"Bottom"`, `"Hidden"`. Valid group sort modes:
`"Group"`, `"Role"`, `"Alphabetical"`.

Examples (shown on the addon's Api panel):

```
/dump FrameSortApi.v3.Sorting:GetFriendlyUnits()
/dump FrameSortApi.v3.Sorting:GetEnemyUnits()
/run FrameSortApi.v3.Sorting:RegisterPostSortCallback(function() print("FrameSort has sorted frames.") end)
/dump FrameSortApi.v3.Sorting:GetPartyFrames()
/run FrameSortApi.v3.Options:SetPlayerSortMode("Arena - 2v2", "Top")
/dump FrameSortApi.v3.Frame:FrameNumberForUnit("arena1")
```

## 10. Troubleshooting by symptom

**"My frames aren't sorting at all."**

1. Open `/fs` and look for the red health warning; the Health Check panel names the
   exact problem and fix.
2. Check the Enabled checkbox for the area you are in (section 3.1). Remember Raid
   (which includes battlegrounds) and Enemy Arena are disabled by default.
3. Confirm your frame addon is supported (section 7). Traditional mode only sorts
   Blizzard party frames; switch to Secure for anything else, then reload.
4. Sorting never happens during combat; it applies when combat ends.
5. Another sorting addon (e.g. SortGroup) or a raid frame addon fighting over the
   same frames can block sorting; the Health Check names tampering addons.

**"Sorting works in arena but not in dungeons" (or any per-area mismatch).**

Each area has separate settings. Check Enabled, Player, and Sort mode for the
specific area. Dungeons use the Dungeon section (delves included), battlegrounds and
raids use the Raid section (off by default), open world groups use World.

**"Raid frames aren't sorting."**

The Raid area is disabled by default; enable it. In Traditional mode also make sure
raid frames use a Combined Groups layout ("Keep Groups Together" off). With Cell,
enable "Combined Groups (Raid)" in Cell -> Layouts.

**"Enemy arena frames aren't sorting."**

Enemy Arena sorting is off by default. It only works in arena, only on MoP+ clients,
and only with Blizzard arena frames or a supported arena addon (sArena, Gladius,
GladiusEx, Gladdy, ElvUI, BattleGroundEnemies, Arena Core). Enemy spec info comes
from the server and can be missing for the first moments at the gates.

**"Spec/role sorting puts people in the wrong order."**

Spec data takes roughly 1-2 seconds per player to arrive, so early ordering can be
provisional. The order itself is controlled by the Ordering panel (role positions)
and the Spec Priority panel (order within a role). "Player top of role" in
Miscellaneous puts you first within your own role.

**"I'm not at the top / I want to be at the bottom."**

Set the Player checkbox (Top/Middle/Bottom/Hidden) in the section for the content
you are in. Each area is configured separately.

**"My frame disappeared."**

The Player mode "Hidden" hides your own frame (Blizzard frames only). Uncheck it to
get the frame back.

**"Spacing isn't working."**

Spacing requires the Secure sorting method and only applies to Blizzard frames.
Range is -1 to 100 per axis; 0 is no spacing.

**"I'm getting Lua errors."**

Traditional sorting mode causes Lua errors by design; the addon's own description
says these are normal and can be ignored. If the errors bother you, use Secure mode.
Otherwise capture them and report on Discord/GitHub, ideally with the Log panel's
"Copy Log" output (enable logging first).

**"My keybind stopped working / targets the wrong player."**

- FrameSort bindings update out of combat only; a mid-fight group change is not
  reflected until combat ends.
- If sorting is disabled for the current area, the bindings target by the frames'
  actual visual order.
- Pets don't count in the numbering; "Target frame 2" is the 2nd player.
- Enemy targeting bindings only work in arena (they follow the sorted enemy list).
- The bindings live in WoW's standard Key Bindings UI (FrameSort "Targeting"
  section); they are unbound by default.

**"My macro stopped working" / "my macro targets the wrong person."**

See Part 2. The most common causes: the header variable count doesn't match the
number of `@`/`target=` selectors (the golden rule); a typo in a variable name
(fails silently, writes the text literally); macros only update out of combat; enemy
variables resolve to `none` outside arena or before spec info arrives; the 255
character limit truncating the macro.

**"Does FrameSort work with <addon>?"**

Check the list in section 7. If the addon is not listed, its frames are not sorted.
Supported addons still need the Secure sorting method (default).

**"The options won't open."**

On Midnight (12.x) and later clients the options cannot be opened during combat.
Leave combat and try `/fs` again.

---

# Part 2 - Macro rules

Reference for writing and reviewing FrameSort macros.
Everything here is derived from the parser in `src/Modules/Macro/Parser.lua` and its
tests in `tests/Macro/ParserTest.lua`.

## 1. What FrameSort actually does

FrameSort does **not** add new macro conditionals to WoW.
It is a find-and-replace engine that **rewrites the saved text of your macro** whenever frames are re-sorted.

1. It scans all 150 macro slots for a `#FrameSort` (or `#FS`) header line.
2. It reads the list of **variables** on that header line.
3. It finds every **unit selector** in the macro body - that is, every `@something` and every `target=something`.
4. It replaces the **1st** selector with the unit resolved from the **1st** variable, the **2nd** selector with the **2nd** variable, and so on.

That positional 1-to-1 mapping is the entire model. Everything below follows from it.

## 2. THE GOLDEN RULE: one variable per `@`

**The number of variables on the header line must equal the number of `@`/`target=` selectors in the macro body.**

This is the single most common mistake. Variables are matched **positionally**, not by name, and *not* per-spell or per-line.

### WRONG - three `@` selectors but only one variable

```
#FrameSort Healer
/cast [@none] A
/cast [mod:shift,@none] B
/cast [mod:ctrl,@none] C
```

Only the *first* `@none` becomes the healer. The 2nd and 3rd stay as the literal unit `none` forever, so those clauses silently do nothing.

### RIGHT - three `@` selectors, three variables

```
#FrameSort Healer Healer Healer
/cast [@none] A
/cast [mod:shift,@none] B
/cast [mod:ctrl,@none] C
```

Repeating the same variable is normal and expected. If you want the same unit in five places, write it five times.

### The same rule inside a single line

Every clause `[...]` that contains an `@` consumes a variable:

```
#FS EnemyHealer EnemyHealer EnemyHealer
/cast [mod:ctrl,@none,harm][mod:shift,@none,harm][@none,harm] Spell
```

3 `@` -> 3 variables.

Clauses **without** an `@` consume nothing:

```
#FS Healer
/cast [mod:shift,help][@none,help][] Spell
```

Only 1 `@`, so only 1 variable. `[mod:shift,help]` and `[]` are skipped.

## 3. The `X` skip variable

`X` means "leave this selector exactly as I typed it". Use it whenever a selector position should keep a hard-coded unit such as `@player`, `@target`, `@focus`, `@mouseover`, or `@cursor`.

```
#FrameSort Healer X Healer
/cast [@none] A
/cast [mod:shift,@player] B
/cast [mod:ctrl,@none] C
```

- Position 1 (`@none`) -> the healer
- Position 2 (`@player`) -> untouched, stays `@player`
- Position 3 (`@none`) -> the healer

`X` is case-insensitive (`x` works too).

### `X` is only needed for *interior* gaps

Variables are consumed left to right. Selectors past the end of the variable list are simply left alone, so you never need trailing `X`s:

```
# these two are identical in behaviour
#FS X X Frame1 X
#FS X X Frame1
/cast [@mouseover,exists][mod:shift,@focus][mod:ctrl,@none][@target][] Spell
```

Both leave `@mouseover`, `@focus`, `@target` untouched and set only the 3rd selector.

### Rule of thumb

Walk the macro top-to-bottom, left-to-right. For every `@` you meet, emit **one** header entry: a FrameSort variable if that slot should be dynamic, or `X` if it should not.

## 4. Variable reference

Variables are **case-insensitive** (`fRaMe1`, `Dps`, `enemyhealer` all work).

### Friendly frames

| Variable | Short | Meaning |
| --- | --- | --- |
| `Frame1`, `Frame2`, ... | `F1`, `F2` | Nth friendly frame in sorted (visual) order |
| `Frame1Pet`, `Frame2Pet`, ... | `F1P`, `F2P` | Pet of the Nth friendly frame |
| `BottomFrame` | `BF` | Last friendly frame |
| `BFM1`, `BFM2`, ... | - | Bottom Frame Minus N (`BFM1` = one above the bottom) |
| `Tank`, `Healer`, `DPS` | `T`, `H`, `D` | First unit with that role |
| `OtherDPS` | `OD` | First DPS that is not you |

### Enemy frames (arena only, MoP+ clients)

| Variable | Short | Meaning |
| --- | --- | --- |
| `EnemyFrame1`, `EnemyFrame2`, ... | `EF1`, `EF2` | Nth enemy arena frame in sorted order |
| `EnemyFrame1Pet`, ... | `EF1P`, ... | Pet of the Nth enemy |
| `EnemyTank`, `EnemyHealer`, `EnemyDPS` | `ET`, `EH`, `ED` | First enemy with that role |

> The in-game settings panel lists `DP` as the abbreviation for `EnemyDPS`. That is a typo in the UI text - the parser only accepts **`ED`**.

### Target-of

Append `Target` (or `TG`) to any of the above to get *that unit's target*:

`TankTarget`, `HealerTarget`, `Frame1Target`, `EnemyHealerTarget`, `HTG`, `F1TG`, `TTG`, ...

### Nth selection

Append a number to pick the Nth match. No number means the 1st.

- `Healer` == `Healer1`
- `DPS3` = 3rd DPS
- `EnemyDPS2` = 2nd enemy DPS
- `Tank2` = 2nd tank

### Special

| Variable | Meaning |
| --- | --- |
| `X` | Skip this selector, leave the text as-is |
| anything else | Written into the macro **literally** |

The literal pass-through means `#FS Focus` produces `@Focus`, and `#FS Bob` produces `@Bob`. It also means **typos fail silently**: `#FS Healr` produces `@Healr`, which is not a valid unit, so the clause just never fires. Always spell variables exactly as listed above.

### Unresolvable variables become `none`

If a variable can't be resolved (group too small, no arena opponents, role info unavailable, wrong game version), FrameSort writes the literal unit `none`. `none` is not a real unit, so the clause fails and the macro falls through to the next clause. This is the intended fail-safe.

## 5. If no FrameSort variable is used, FrameSort isn't needed

A `#FrameSort` header only earns its place if **at least one** entry is a variable that FrameSort actually resolves - one whose value changes as frames are re-sorted or as the group changes.

**Dynamic - these are FrameSort variables:**
`Frame1`...`FrameN`, `Frame1Pet`..., `BottomFrame`, `BFM1`..., `Tank`, `Healer`, `DPS`, `OtherDPS`, `EnemyFrame1`..., `EnemyFrame1Pet`..., `EnemyTank`, `EnemyHealer`, `EnemyDPS`, their abbreviations, and any of them with a `Target`/`TG` suffix.

**Not dynamic - these are *not* FrameSort variables:**
`X` (skip), and any built-in WoW unit written literally: `player`, `target`, `focus`, `mouseover`, `cursor`, `pet`, `targettarget`, `party1`-`party4`, `raid1`-`raid40`, `arena1`-`arena3`, `boss1`..., or a character name.

If **every** header entry is `X` or a literal Blizzard unit, the header does nothing useful. FrameSort will dutifully rewrite text that never changes, and the macro behaves exactly the same with the header deleted. **Drop the header and hand back a plain WoW macro.**

### Pointless - no dynamic variable

```
#showtooltip
#FS X Player
/cast [@mouseover,help][@none,help] Spell
```

`X` skips the first selector and `Player` just writes the literal unit `player` into the second. Nothing here depends on frame order.

### Same behaviour, no FrameSort needed

```
#showtooltip
/cast [@mouseover,help][@player,help] Spell
```

Other headers that do nothing:

- `#FS X X X` - all skips.
- `#FS Mouseover Target` - both are built-in units; write `@mouseover` and `@target` directly.
- `#FS Party1 Party2` - party numbers are fixed; FrameSort exists precisely to avoid these.

A header is worthwhile as soon as **one** entry is dynamic. `#FS X OtherDPS Healer` is fine - the `X` is doing its job of protecting a hard-coded `@player`.

When a request genuinely doesn't need FrameSort, say so and give the plain macro rather than adding a header for the sake of it.

## 6. Placeholder conventions

The placeholder text you type after `@` is **irrelevant** - it gets overwritten. `@none`, `@a`, `@doesntmatter`, `@placeholder`, `@healer` are all equivalent as a starting value.

**Prefer `@none`.** If FrameSort hasn't run yet (fresh install, solo, macro just typed), `@none` makes the clause fail cleanly instead of targeting something unexpected.

Do **not** write `@healer` and assume WoW understands it - it doesn't. It only works because FrameSort replaces the text.

## 7. Header rules

```
#showtooltip
#FrameSort Healer Healer
/cast ...
```

- The header is `#FrameSort` or the short form `#FS`, case-insensitive (`#framesort`, `#fs`, `#FRAMESORT`, `#Fs`).
- **One header line per macro.** If both a `#FrameSort` and a `#FS` line exist, the long one wins and the other is ignored.
- The header must **not be the last line** of the macro - the parser requires a newline after it.
- Variables are split on any non-alphanumeric character, so separators are interchangeable. These are all identical:
  ```
  #FS Frame1 Frame2 Frame3
  #FS Frame1, Frame2, Frame3
  #FS Frame1|Frame2|Frame3
  #FrameSort: Frame1, Frame2, Frame3
  ```
- Because of that split, **never put a comment on the header line**. `#FS Healer -- my healer macro` parses as the variables `Healer`, `my`, `healer`, `macro`.
- Never put an `@` on the header line or in `#showtooltip` - see gotcha 8.2.

## 8. Gotchas

### 8.1 Selectors are counted across the *whole* macro

The counter does not reset per line, per `/cast`, or per clause. A 4-line macro with one `@` per line needs 4 variables.

### 8.2 *Every* `@` in the body counts - including ones you didn't think of

The scan starts at character 1 of the macro and includes the `#showtooltip` line and the header line. If you write `#showtooltip [@none] Spell`, that `@none` becomes selector #1 and shifts every other position by one. Keep `@` out of `#showtooltip` and out of the header.

### 8.3 Both `@unit` and `target=unit` count, and they can be mixed

```
#FS Frame1, Frame2, Frame3
/cast [target=a,exists] Spell
/cast [@b,exists] Spell
/cast [target=c,exists] Spell
```

Write `target=unit` with **no spaces** around the `=`. `target = player` is not recognised.

Likewise no space after `@`: `@ none` is not recognised.

### 8.4 Extra variables are ignored; extra selectors are left alone

Neither is an error, which is exactly why miscounts fail silently. Nothing warns you.

### 8.5 Variables can't contain non-alphanumeric characters

Hyphens, apostrophes and accented letters break a variable into pieces. `#FS Bob-Ravencrest` parses as **two** variables (`Bob` and `Ravencrest`), which throws off every position after it. Use `Frame1`/`Tank`/`X` rather than character names when a realm name is involved.

### 8.6 Roles and enemy roles are not always available

- `Tank` / `Healer` / `DPS` / `OtherDPS` need role assignments. Where the client has no role system, they resolve to `none`.
- `EnemyTank` / `EnemyHealer` / `EnemyDPS` need specialization data and only resolve **inside arenas** (MoP and later). Outside arena they are `none`.
- Enemy specs come from inspection, so right at the arena gates they may briefly be `none`.

Always give enemy macros a sensible fallback clause, e.g. `[@none,harm][@target,harm]`.

### 8.7 Macros only update out of combat

`EditMacro` is protected, so FrameSort defers macro rewrites until combat ends. A macro resolves to whatever the group looked like at the last out-of-combat update. Don't expect `@Healer` to re-point mid-fight if roles change.

### 8.8 FrameSort edits the saved macro text

After the first update your macro literally reads `/cast [@party3,help] Spell`. That is normal. Keep the `#FrameSort` header - it is the only record of your intent.

### 8.9 The 255 character limit

Macro bodies are capped at 255 characters and the header counts toward it. Use `#FS` and the short variable forms (`F1`, `H`, `EH`, `OD`) when tight.

### 8.10 `BF1` is not `Frame1`

Digits are stripped when resolving the variable type, so `BF1`/`BF2` all mean `BottomFrame`. For "one from the bottom" use `BFM1`.

## 9. Validation checklist

Before returning a macro, verify:

1. **Count** the `@` and `target=` occurrences in the *entire* body, including `#showtooltip`.
2. **Count** the variables on the header line.
3. Are they equal, with `X` filling every hard-coded position? If not, fix it.
4. Is every variable spelled exactly as in section 4?
5. Is **at least one** entry a dynamic FrameSort variable? If they're all `X` or literal Blizzard units, drop the header and return a plain macro (section 5).
6. Do the variables appear in the same order as the selectors (top-to-bottom, left-to-right)?
7. Is there exactly one header line, and is it not the last line?
8. Are placeholders `@none` (unless intentionally hard-coded and marked `X`)?
9. Is the body under 255 characters?

## 10. Worked example

Request: *"Cast Blessing of Freedom on my healer, hold shift for the other DPS, hold alt for myself."*

Draft the clauses first:

```
/cast [mod:alt,@player][mod:shift,@none,help][@none,help] Blessing of Freedom
```

Now walk the selectors left to right:

| # | Selector | Intent | Header entry |
| --- | --- | --- | --- |
| 1 | `@player` | hard-coded self | `X` |
| 2 | `@none` | other DPS | `OtherDPS` |
| 3 | `@none` | healer | `Healer` |

Result:

```
#showtooltip
#FS X OtherDPS Healer
/cast [mod:alt,@player][mod:shift,@none,help][@none,help] Blessing of Freedom
```

3 selectors, 3 header entries. Correct.

---

# Part 3 - Macro examples

Every example below obeys the golden rule: the header line has one entry for every `@` (or `target=`) in the macro body, in the same order, with `X` marking any selector that should be left alone.

## Counting Examples

One `@`, one variable:

```
#showtooltip
#FS Healer
/cast [@none,help] Spell
```

Three `@`, three variables (repeat the variable - do not write it once):

```
#showtooltip
#FS Healer Healer Healer
/cast [@none,help] A
/cast [mod:shift,@none,help] B
/cast [mod:ctrl,@none,help] C
```

Three `@` on one line, three variables:

```
#showtooltip
#FS EnemyHealer EnemyHealer EnemyHealer
/cast [mod:ctrl,@none,harm][mod:shift,@none,harm][@none,harm] Spell
```

Use `X` to keep a hard-coded unit in the middle of the list:

```
#showtooltip
#FS Healer X Healer
/cast [@none,help] A
/cast [mod:shift,@player] B
/cast [mod:ctrl,@none,help] C
```

Trailing selectors need no `X` - variables run out and the rest are left alone:

```
#showtooltip
#FS Healer
/cast [@none,help][@player] Spell
```

Clauses with no `@` cost nothing:

```
#showtooltip
#FS Healer
/cast [mod:shift,help][@none,help][] Spell
```

## Death Knight Macros

Cast Anti-Magic Shell on your healer:

```
#showtooltip
#FS Healer
/cast [@none,help] Anti-Magic Shell
```

Death Grip the enemy healer, hold shift for your current target:

```
#showtooltip
#FS EnemyHealer X
/cast [mod:shift,@target,harm][@none,harm] Death Grip
```

Strangulate the enemy healer:

```
#showtooltip
#FS EnemyHealer
/cast [@none,harm] Strangulate
```

Asphyxiate the enemy healer, defaulting to your target:

```
#showtooltip
#FS EnemyHealer X
/cast [@none,harm][@target,harm] Asphyxiate
```

## Demon Hunter Macros

Disrupt the enemy healer:

```
#showtooltip
#FS EnemyHealer
/cast [@none,harm] Disrupt
```

Imprison the enemy healer, hold shift for the first enemy DPS:

```
#showtooltip
#FS EnemyDPS EnemyHealer
/cast [mod:shift,@none,harm][@none,harm] Imprison
```

## Druid Macros

Innervate your target if friendly, default to healer:

```
#showtooltip
#FrameSort X Healer
/cast [@target,help][@none,help] Innervate
```

Entangling roots and solar beam the healer:

```
#showtooltip Solar Beam
#FrameSort EnemyHealer EnemyHealer
/cast [@none,harm] Entangling Roots
/cast [@none,harm] Solar Beam
```

Ironbark on your healer, shift for the other dps, alt for yourself:

```
#showtooltip
#FS X OtherDPS Healer
/cast [mod:alt,@player][mod:shift,@none,help][@none,help] Ironbark
```

Cyclone the enemy healer, hold shift for your current target:

```
#showtooltip
#FS EnemyHealer X
/cast [@none,harm][mod:shift,@target,harm] Cyclone
```

Rebirth your healer:

```
#showtooltip
#FS Healer
/cast [@none] Rebirth
```

Nature's Cure your healer, shift for the other dps:

```
#showtooltip
#FS OtherDPS Healer
/cast [mod:shift,@none,help][@none,help] Nature's Cure
```

## Evoker Macros

Rescue your healer:

```
#showtooltip
#FS Healer
/cast [@none,help] Rescue
```

Quell the enemy healer:

```
#showtooltip
#FS EnemyHealer
/cast [@none,harm] Quell
```

Sleep Walk the enemy healer:

```
#showtooltip
#FS EnemyHealer
/cast [@none,harm] Sleep Walk
```

Cauterizing Flame on your healer, alt for yourself:

```
#showtooltip
#FS X Healer
/cast [mod:alt,@player][@none,help] Cauterizing Flame
```

## Hunter Macros

Cast Roar of Sacrifice on your healer, hold alt for self, and shift for other dps:

```
#showtooltip
#FrameSort X OtherDPS Healer
/cast [mod:alt,@player][mod:shift,@none,help][@none,help] Roar of Sacrifice
```

Cast Master's Call on your healer:

```
#showtooltip
#FrameSort Healer
/target [@none]
/cast Master's Call
/targetlasttarget
```

Cast Misdirection on your tank:

```
#showtooltip
#FS Tank
/cast [@none,help] Misdirection
```

Intimidation on the enemy healer:

```
#showtooltip
#FS EnemyHealer
/cast [@none,harm] Intimidation
```

Counter Shot the enemy healer:

```
#showtooltip
#FS EnemyHealer
/cast [@none,harm] Counter Shot
```

Tranquilizing Shot the enemy healer, shift for the first enemy dps:

```
#showtooltip
#FS EnemyDPS EnemyHealer
/cast [mod:shift,@none,harm][@none,harm] Tranquilizing Shot
```

## Mage Macros

Counterspell the enemy healer:

```
#showtooltip
#FS EnemyHealer
/cast [@none,harm] Counterspell
```

Polymorph the enemy healer, hold shift for your current target:

```
#showtooltip
#FS EnemyHealer X
/cast [@none,harm][mod:shift,@target,harm] Polymorph
```

Spellsteal the enemy healer:

```
#showtooltip
#FS EnemyHealer
/cast [@none,harm] Spellsteal
```

Remove Curse on your healer, shift for the other dps, alt for yourself:

```
#showtooltip
#FS X OtherDPS Healer
/cast [mod:alt,@player][mod:shift,@none,help][@none,help] Remove Curse
```

Ice Block yourself, or Remove Curse from the healer on shift:

```
#showtooltip
#FS X Healer
/cast [nomod,@player] Ice Block
/cast [mod:shift,@none,help] Remove Curse
```

## Monk Macros

Life Cocoon your healer:

```
#showtooltip
#FS Healer
/cast [@none,help] Life Cocoon
```

Spear Hand Strike the enemy healer:

```
#showtooltip
#FS EnemyHealer
/cast [@none,harm] Spear Hand Strike
```

Paralysis on the enemy healer, hold shift for your current target:

```
#showtooltip
#FS EnemyHealer X
/cast [@none,harm][mod:shift,@target,harm] Paralysis
```

Detox your healer, shift for the other dps:

```
#showtooltip
#FS OtherDPS Healer
/cast [mod:shift,@none,help][@none,help] Detox
```

## Paladin Macros

Cast Blessing of Sanctuary on your healer:

```
#showtooltip
#FS Healer
/cast [@none,exists][@player] Blessing of Sanctuary
```

Cast Blessing of Protection on your healer, hold alt to cast on self, and shift to cast on other dps,

```
#showtooltip
#FS X OtherDPS Healer
/cast [mod:alt,@player][mod:shift,@none,help][@none,help] Blessing of Protection
```

Cast Blessing of Sacrifice on your healer, hold shift to cast on other dps:

```
#showtooltip
#FS OtherDPS Healer
/cast [mod:shift,@none,help][@none,help] Blessing of Sacrifice
```

Cast Lay on Hands on your healer:

```
#showtooltip
#FS Healer
/cast [@none,help] Lay on Hands
```

Cast Judgement on the first enemy dps:

```
#showtooltip
#FrameSort EnemyDPS
/cast [@none,exists] Judgment
```

Blessing of Freedom on your healer, shift for the other dps, alt for yourself:

```
#showtooltip
#FS X OtherDPS Healer
/cast [mod:alt,@player][mod:shift,@none,help][@none,help] Blessing of Freedom
```

Hammer of Justice the enemy healer:

```
#showtooltip
#FS EnemyHealer
/cast [@none,harm] Hammer of Justice
```

Rebuke the enemy healer:

```
#showtooltip
#FS EnemyHealer
/cast [@none,harm] Rebuke
```

Cleanse each party member with a modifier:

```
#showtooltip
#FS Frame1 Frame2 Frame3 Frame4
/cast [mod:ctrl,@none,help][mod:shift,@none,help][mod:alt,@none,help][@none,help] Cleanse
```

## Priest Macros

Pain Suppression your healer, shift for the other dps:

```
#showtooltip
#FS OtherDPS Healer
/cast [mod:shift,@none,help][@none,help] Pain Suppression
```

Guardian Spirit your healer:

```
#showtooltip
#FS Healer
/cast [@none,help] Guardian Spirit
```

Power Infusion on the other dps, alt for yourself:

```
#showtooltip
#FS X OtherDPS
/cast [mod:alt,@player][@none,help] Power Infusion
```

Leap of Faith the other dps, shift for the healer:

```
#showtooltip
#FS Healer OtherDPS
/cast [mod:shift,@none,help][@none,help] Leap of Faith
```

Silence the enemy healer:

```
#showtooltip
#FS EnemyHealer
/cast [@none,harm] Silence
```

Purify your healer, shift for the other dps, alt for yourself:

```
#showtooltip
#FS X OtherDPS Healer
/cast [mod:alt,@player][mod:shift,@none,help][@none,help] Purify
```

## Rogue Macros

Cast Shadowstep and Kick on enemy healer:

```
#showtooltip
#FrameSort EnemyHealer EnemyHealer
/cast [@none,harm] Shadowstep
/cast [@none,harm] Kick
```

Cast Sap on enemy healer:

```
#showtooltip
#FrameSort EnemyHealer
/cast [@none,harm] Sap
```

Cast Tricks of the Trade on the other dps:

```
#showtooltip
#FrameSort OtherDPS
/cast [@none,help] Tricks of the Trade
```

Blind the enemy healer, hold shift for your current target:

```
#showtooltip
#FrameSort EnemyHealer X
/cast [@none,harm][mod:shift,@target,harm] Blind
```

Kidney Shot the enemy healer:

```
#showtooltip
#FS EnemyHealer
/cast [@none,harm] Kidney Shot
```

## Shaman Macros

Wind Shear the enemy healer:

```
#showtooltip
#FS EnemyHealer
/cast [@none,harm] Wind Shear
```

Purge the enemy healer, shift for the first enemy dps:

```
#showtooltip
#FS EnemyDPS EnemyHealer
/cast [mod:shift,@none,harm][@none,harm] Purge
```

Hex the enemy healer, hold shift for your current target:

```
#showtooltip
#FS EnemyHealer X
/cast [@none,harm][mod:shift,@target,harm] Hex
```

Earth Shield your tank, shift for your healer:

```
#showtooltip
#FS Healer Tank
/cast [mod:shift,@none,help][@none,help] Earth Shield
```

Cleanse Spirit your healer, shift for the other dps, alt for yourself:

```
#showtooltip
#FS X OtherDPS Healer
/cast [mod:alt,@player][mod:shift,@none,help][@none,help] Cleanse Spirit
```

## Warlock Macros

Soulstone your healer:

```
#showtooltip
#FS Healer
/cast [@none,help] Soulstone
```

Spell Lock the enemy healer:

```
#showtooltip
#FS EnemyHealer
/cast [@none,harm] Spell Lock
```

Fear the enemy healer, hold shift for your current target:

```
#showtooltip
#FS EnemyHealer X
/cast [@none,harm][mod:shift,@target,harm] Fear
```

Devour Magic the enemy healer, shift to dispel your own healer:

```
#showtooltip
#FS Healer EnemyHealer
/cast [mod:shift,@none,help][@none,harm] Devour Magic
```

## Warrior Macros

Intervene your healer:

```
#showtooltip
#FS Healer
/cast [@none,help] Intervene
```

Pummel the enemy healer:

```
#showtooltip
#FS EnemyHealer
/cast [@none,harm] Pummel
```

Storm Bolt the enemy healer, hold shift for your current target:

```
#showtooltip
#FS EnemyHealer X
/cast [@none,harm][mod:shift,@target,harm] Storm Bolt
```

Shattering Throw on the other dps:

```
#showtooltip
#FS OtherDPS
/cast [@none,help] Shattering Throw
```

## Frame Position Macros

Cast on frames by their visual position rather than party number:

```
#showtooltip
#FS Frame1 Frame2 Frame3
/cast [mod:ctrl,@none,help][mod:shift,@none,help][@none,help] Spell
```

Cast on the bottom frame, shift for one above the bottom:

```
#showtooltip
#FS BFM1 BottomFrame
/cast [mod:shift,@none,help][@none,help] Spell
```

Cast on the second healer in a raid:

```
#showtooltip
#FS Healer2
/cast [@none,help] Spell
```

Cast on the first frame's pet:

```
#showtooltip
#FS Frame1Pet
/cast [@none,help] Spell
```

Cast on whatever the tank is targeting:

```
#showtooltip
#FS TankTarget
/cast [@none,harm] Spell
```

## General Macros

Use "X" to tell FrameSort to skip a unit selector:

```
#showtooltip
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,harm][@none,exists][] Spell
```

Set enemy healer as your focus:

```
#FS EnemyHealer
/focus [@none]
```

Assist your tank:

```
#FS Tank
/assist [@none]
```

Mouseover first, then fall back to your healer:

```
#showtooltip
#FS X Healer
/cast [@mouseover,help][@none,help] Spell
```

Reaching the 255 character limit? Use the short header and abbreviations:

```
#FS F1 F2 F3
/cast [mod:ctrl,@a][mod:shift,@b][@c] Spell
```

The long `target=` syntax works too, and can be mixed with `@`:

```
#showtooltip
#FS Frame1 Frame2 Frame3
/cast [target=none,exists] Spell
/cast [@none,exists] Spell
/cast [target=none,exists] Spell
```
