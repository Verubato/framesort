# FrameSort Macro Bot Instructions

Reference for writing and reviewing FrameSort macros.
Everything here is derived from the parser in `src/Modules/Macro/Parser.lua` and its tests in `tests/Macro/ParserTest.lua`.

---

# Part 1 — Rules

## 1. What FrameSort actually does

FrameSort does **not** add new macro conditionals to WoW.
It is a find-and-replace engine that **rewrites the saved text of your macro** whenever frames are re-sorted.

1. It scans all 150 macro slots for a `#FrameSort` (or `#FS`) header line.
2. It reads the list of **variables** on that header line.
3. It finds every **unit selector** in the macro body — that is, every `@something` and every `target=something`.
4. It replaces the **1st** selector with the unit resolved from the **1st** variable, the **2nd** selector with the **2nd** variable, and so on.

That positional 1-to-1 mapping is the entire model. Everything below follows from it.

## 2. THE GOLDEN RULE: one variable per `@`

**The number of variables on the header line must equal the number of `@`/`target=` selectors in the macro body.**

This is the single most common mistake. Variables are matched **positionally**, not by name, and *not* per-spell or per-line.

### ❌ WRONG — three `@` selectors but only one variable

```
#FrameSort Healer
/cast [@none] A
/cast [mod:shift,@none] B
/cast [mod:ctrl,@none] C
```

Only the *first* `@none` becomes the healer. The 2nd and 3rd stay as the literal unit `none` forever, so those clauses silently do nothing.

### ✅ RIGHT — three `@` selectors, three variables

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

3 `@` → 3 variables.

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

- Position 1 (`@none`) → the healer
- Position 2 (`@player`) → untouched, stays `@player`
- Position 3 (`@none`) → the healer

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
| `Frame1`, `Frame2`, … | `F1`, `F2` | Nth friendly frame in sorted (visual) order |
| `Frame1Pet`, `Frame2Pet`, … | `F1P`, `F2P` | Pet of the Nth friendly frame |
| `BottomFrame` | `BF` | Last friendly frame |
| `BFM1`, `BFM2`, … | — | Bottom Frame Minus N (`BFM1` = one above the bottom) |
| `Tank`, `Healer`, `DPS` | `T`, `H`, `D` | First unit with that role |
| `OtherDPS` | `OD` | First DPS that is not you |

### Enemy frames (arena only, MoP+ clients)

| Variable | Short | Meaning |
| --- | --- | --- |
| `EnemyFrame1`, `EnemyFrame2`, … | `EF1`, `EF2` | Nth enemy arena frame in sorted order |
| `EnemyFrame1Pet`, … | `EF1P`, … | Pet of the Nth enemy |
| `EnemyTank`, `EnemyHealer`, `EnemyDPS` | `ET`, `EH`, `ED` | First enemy with that role |

> The in-game settings panel lists `DP` as the abbreviation for `EnemyDPS`. That is a typo in the UI text — the parser only accepts **`ED`**.

### Target-of

Append `Target` (or `TG`) to any of the above to get *that unit's target*:

`TankTarget`, `HealerTarget`, `Frame1Target`, `EnemyHealerTarget`, `HTG`, `F1TG`, `TTG`, …

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

## 5. Placeholder conventions

The placeholder text you type after `@` is **irrelevant** — it gets overwritten. `@none`, `@a`, `@doesntmatter`, `@placeholder`, `@healer` are all equivalent as a starting value.

**Prefer `@none`.** If FrameSort hasn't run yet (fresh install, solo, macro just typed), `@none` makes the clause fail cleanly instead of targeting something unexpected.

Do **not** write `@healer` and assume WoW understands it — it doesn't. It only works because FrameSort replaces the text.

## 6. Header rules

```
#showtooltip
#FrameSort Healer Healer
/cast ...
```

- The header is `#FrameSort` or the short form `#FS`, case-insensitive (`#framesort`, `#fs`, `#FRAMESORT`, `#Fs`).
- **One header line per macro.** If both a `#FrameSort` and a `#FS` line exist, the long one wins and the other is ignored.
- The header must **not be the last line** of the macro — the parser requires a newline after it.
- Variables are split on any non-alphanumeric character, so separators are interchangeable. These are all identical:
  ```
  #FS Frame1 Frame2 Frame3
  #FS Frame1, Frame2, Frame3
  #FS Frame1|Frame2|Frame3
  #FrameSort: Frame1, Frame2, Frame3
  ```
- Because of that split, **never put a comment on the header line**. `#FS Healer -- my healer macro` parses as the variables `Healer`, `my`, `healer`, `macro`.
- Never put an `@` on the header line or in `#showtooltip` — see gotcha 7.2.

## 7. Gotchas

### 7.1 Selectors are counted across the *whole* macro

The counter does not reset per line, per `/cast`, or per clause. A 4-line macro with one `@` per line needs 4 variables.

### 7.2 *Every* `@` in the body counts — including ones you didn't think of

The scan starts at character 1 of the macro and includes the `#showtooltip` line and the header line. If you write `#showtooltip [@none] Spell`, that `@none` becomes selector #1 and shifts every other position by one. Keep `@` out of `#showtooltip` and out of the header.

### 7.3 Both `@unit` and `target=unit` count, and they can be mixed

```
#FS Frame1, Frame2, Frame3
/cast [target=a,exists] Spell
/cast [@b,exists] Spell
/cast [target=c,exists] Spell
```

Write `target=unit` with **no spaces** around the `=`. `target = player` is not recognised.

Likewise no space after `@`: `@ none` is not recognised.

### 7.4 Extra variables are ignored; extra selectors are left alone

Neither is an error, which is exactly why miscounts fail silently. Nothing warns you.

### 7.5 Variables can't contain non-alphanumeric characters

Hyphens, apostrophes and accented letters break a variable into pieces. `#FS Bob-Ravencrest` parses as **two** variables (`Bob` and `Ravencrest`), which throws off every position after it. Use `Frame1`/`Tank`/`X` rather than character names when a realm name is involved.

### 7.6 Roles and enemy roles are not always available

- `Tank` / `Healer` / `DPS` / `OtherDPS` need role assignments. Where the client has no role system, they resolve to `none`.
- `EnemyTank` / `EnemyHealer` / `EnemyDPS` need specialization data and only resolve **inside arenas** (MoP and later). Outside arena they are `none`.
- Enemy specs come from inspection, so right at the arena gates they may briefly be `none`.

Always give enemy macros a sensible fallback clause, e.g. `[@none,harm][@target,harm]`.

### 7.7 Macros only update out of combat

`EditMacro` is protected, so FrameSort defers macro rewrites until combat ends. A macro resolves to whatever the group looked like at the last out-of-combat update. Don't expect `@Healer` to re-point mid-fight if roles change.

### 7.8 FrameSort edits the saved macro text

After the first update your macro literally reads `/cast [@party3,help] Spell`. That is normal. Keep the `#FrameSort` header — it is the only record of your intent.

### 7.9 The 255 character limit

Macro bodies are capped at 255 characters and the header counts toward it. Use `#FS` and the short variable forms (`F1`, `H`, `EH`, `OD`) when tight.

### 7.10 `BF1` is not `Frame1`

Digits are stripped when resolving the variable type, so `BF1`/`BF2` all mean `BottomFrame`. For "one from the bottom" use `BFM1`.

## 8. Validation checklist

Before returning a macro, verify:

1. **Count** the `@` and `target=` occurrences in the *entire* body, including `#showtooltip`.
2. **Count** the variables on the header line.
3. Are they equal, with `X` filling every hard-coded position? If not, fix it.
4. Is every variable spelled exactly as in section 4?
5. Do the variables appear in the same order as the selectors (top-to-bottom, left-to-right)?
6. Is there exactly one header line, and is it not the last line?
7. Are placeholders `@none` (unless intentionally hard-coded and marked `X`)?
8. Is the body under 255 characters?

## 9. Worked example

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

3 selectors, 3 header entries. ✅

---

# Part 2 — Examples

Every example below obeys the golden rule: the header line has one entry for every `@` (or `target=`) in the macro body, in the same order, with `X` marking any selector that should be left alone.

## Counting Examples

One `@`, one variable:

```
#showtooltip
#FS Healer
/cast [@none,help] Spell
```

Three `@`, three variables (repeat the variable — do not write it once):

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

Trailing selectors need no `X` — variables run out and the rest are left alone:

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
