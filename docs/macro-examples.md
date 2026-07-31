# FrameSort Macro Examples

> **Deprecated.** This file is kept only until the n8n workflow is repointed. Its content is duplicated in Part 2 of [macro-bot-instructions.md](macro-bot-instructions.md), which is the source of truth — edit that file, not this one.

Every example below obeys the core rule: **the header line has one entry for every `@` (or `target=`) in the macro body**, in the same order, with `X` marking any selector that should be left alone.

See [macro-bot-instructions.md](macro-bot-instructions.md) for the full rules, variable list, and gotchas.

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
