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

## Rogue Macros

Cast Shadowstep and Kick on enemy healer:

```
#showtooltip
#FrameSort EnemyHealer EnemyHealer
/cast [@doesntmatter,harm] Shadowstep
/cast [@placeholder,harm] Kick
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

## Warrior Macros

Intervene your healer:

```
#showtooltip
#FS Healer
/cast [@none,help] Intervene
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

## Death Knight Macros

Cast Anti-Magic Shell on your healer:

```
#showtooltip
#FS Healer
/cast [@none,help] Anti-Magic Shell
```

## General Macros

Use "X" to tell FrameSort to skip a unit selector:

```
#showtooltip
#FS X X EnemyHealer
/cast [mod:shift,@focus][@mouseover,harm][@enemyhealer,exists][] Spell
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
