# FrameSort #

A simple WoW addon that sorts party/raid/arena frames and places you at the top/middle/bottom.

## Features ##

* Place your raid frame at the top, middle, or bottom.
* Sort the remaining frames by group/role/alphabetical.
* Works with Blizzard, Gladius, GladiusEx, sArena, ElvUI, and Cell.
* Automatically promote healers to leader in solo shuffle.
* Keybindings to target frames based on their visual position rather than their party number.
* Macro variables for @Healer, @EnemyHealer, @Frame, and more.
* Add spacing between frames.

## Sorting ##

Order raid frames the way you like with your frame on top:

![Player at the top](https://raw.githubusercontent.com/Verubato/framesort/main/assets/Screenshots/3v3-sorting-top.png)

Or on bottom:

![Player at the bottom](https://raw.githubusercontent.com/Verubato/framesort/main/assets/Screenshots/3v3-sorting-bottom.png)

The middle position is also supported.

## Spacing ##

Add spacing between frames:

![Party](https://raw.githubusercontent.com/Verubato/framesort/main/assets/Screenshots/party-spacing.png)

![Battlegrounds](https://raw.githubusercontent.com/Verubato/framesort/main/assets/Screenshots/raid-spacing.png)

## Targeting ##

Target frames based on their visual position:

![Keybindings](https://raw.githubusercontent.com/Verubato/framesort/main/assets/Screenshots/f1-f5-keybindings.png)

## Example Macros ##

### Are you a ret paladin and your healer is feared/stunned? ###

```lua
#showtooltip
#FrameSort Healer
/cast [@healer] Blessing of Sanctuary
```

### Cast power infusion on your other DPS ###

```lua
#showtooltip
#FrameSort OtherDps
/cast [@otherdps,exists][] Power Infusion
```

### Death grip the healer without having to set focus ###

```lua
#FrameSort EnemyHealer
/cast [@enemyhealer] Death Grip
```

### Target whatever the tank is targeting ###

```lua
#FrameSort Tank
/assist [@tank]
```

### Reaching the 255 macro limit? Use abbreviations ###

```lua
#FS F1 F2 F3
/cast [mod:ctrl,@a][mod:shift,@b][@c] Spell
```

### Variables ###

Refer to the Macro page FrameSort's settings page for a full list of supported variables.

## Xaryu Explains ##

[![Xaryu's Explanation on YouTube](https://i.ytimg.com/vi/2PiKjvT30cM/hqdefault.jpg)](https://www.youtube.com/watch?v=2PiKjvT30cM&t=212s)

## Install ##

The addon can be installed via:

* [CurseForge](https://www.curseforge.com/wow/addons/framesort)
* [Wago.io](https://addons.wago.io/addons/framesort)
* [WowUp](https://wowup.io/)
* [Manually](https://github.com/Verubato/framesort/releases/latest)

## Support ##

* [Discord](https://discord.gg/UruPTPHHxK)
* [GitHub](https://github.com/Verubato/framesort/issues)
