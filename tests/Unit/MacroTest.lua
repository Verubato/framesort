---@diagnostic disable: inject-field
local deps = {
    "Collections\\Enumerable.lua",
    "Modules\\Macro\\Parser.lua",
}

local addon = {
    Collections = {},
    Modules = {
        Macro = {}
    },
    WoW = {
        Api = require("Mock\\WoW"),
    },
}

local helper = require("Helper")
helper:LoadDependencies(addon, deps)

local fsMacro = addon.Modules.Macro.Parser
local M = {}

function M:setup()
    addon.WoW.Api.IsInGroup = function()
        return true
    end
end

function M:test_is_framesort_macro()
    assertEquals(
        fsMacro:IsFrameSortMacro([[
        #FrameSort
        ]]),
        true
    )

    assertEquals(
        fsMacro:IsFrameSortMacro([[
        #framesort
        ]]),
        true
    )

    assertEquals(
        fsMacro:IsFrameSortMacro([[
        #FRAMESORT
        ]]),
        true
    )
    assertEquals(
        fsMacro:IsFrameSortMacro([[
        #showtooltip
        #framesort frame1
        /cast [@a] Spell;
        ]]),
        true
    )

    assertEquals(
        fsMacro:IsFrameSortMacro([[
        #FrameSort: Frame1, Frame2
        /cast [help, @none] Spell; [harm, @none] Spell2;
        ]]),
        true
    )
end

function M:test_is_not_framesort_macro()
    assertEquals(
        fsMacro:IsFrameSortMacro([[
        #showtooltip
        /cast Moonfire;
        ]]),
        false
    )

    assertEquals(
        fsMacro:IsFrameSortMacro([[
        /cast [@none] Spell
        ]]),
        false
    )
end

function M:test_separators()
    local units = { "party2", "party4", "party1", "party2", "player" }
    local macroText = [[
        #showtooltip
        #FrameSort Frame1, Frame2, Frame3, Frame4, Frame5
        /cast [@a][@b][@c][@d][@e] Spell
    ]]
    local expected = [[
        #showtooltip
        #FrameSort Frame1, Frame2, Frame3, Frame4, Frame5
        /cast [@party2][@party4][@party1][@party2][@player] Spell
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #FrameSort: Frame1 Frame2 Frame3 Frame4 Frame5
        /cast [@a][@b][@c][@d][@e] Spell
    ]]
    expected = [[
        #showtooltip
        #FrameSort: Frame1 Frame2 Frame3 Frame4 Frame5
        /cast [@party2][@party4][@party1][@party2][@player] Spell
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #FrameSort - Frame1|Frame2|Frame3|Frame4|Frame5
        /cast [@a][@b][@c][@d][@e] Spell
    ]]
    expected = [[
        #showtooltip
        #FrameSort - Frame1|Frame2|Frame3|Frame4|Frame5
        /cast [@party2][@party4][@party1][@party2][@player] Spell
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_one_selector()
    local units = { "player", "party1", "party2", "party3", "party4" }

    addon.WoW.Api.UnitGroupRolesAssigned = function(x)
        if x == "party1" then
            return "HEALER"
        end

        return "DAMAGER"
    end

    local macroText = [[
        #showtooltip
        #framesort Healer
        /cast [@none,exists][mod:shift,@focus][@mouseover,harm][] Spell;
    ]]
    local expected = [[
        #showtooltip
        #framesort Healer
        /cast [@party1,exists][mod:shift,@focus][@mouseover,harm][] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_frame_123456()
    local units = { "party2", "party1", "player", "raid17", "raid4", "asdf1" }
    local macroText = [[
        #showtooltip
        #FrameSort Frame1 Frame2 Frame3 Frame4 Frame5 Frame6
        /cast [mod:ctrl,@a][mod:shift,@b][nomod,@c][something,@d][test,@e][@f] Spell
    ]]
    local expected = [[
        #showtooltip
        #FrameSort Frame1 Frame2 Frame3 Frame4 Frame5 Frame6
        /cast [mod:ctrl,@party2][mod:shift,@party1][nomod,@player][something,@raid17][test,@raid4][@asdf1] Spell
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_enemy_frame_123456()
    local units = { "arena2", "arena3", "arena1" }
    local macroText = [[
        #showtooltip
        #FrameSort EnemyFrame1 EnemyFrame2 EnemyFrame3
        /cast [mod:ctrl,@a][mod:shift,@b][nomod,@c] Spell
    ]]
    local expected = [[
        #showtooltip
        #FrameSort EnemyFrame1 EnemyFrame2 EnemyFrame3
        /cast [mod:ctrl,@arena2][mod:shift,@arena3][nomod,@arena1] Spell
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, {}, units), expected)
end

function M:test_player()
    local units = { "player", "party1", "party2", "party3", "party4" }

    local macroText = [[
        #showtooltip
        #framesort player
        /cast [@none] Spell;
    ]]
    local expected = [[
        #showtooltip
        #framesort player
        /cast [@player] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_tank()
    local units = { "player", "party1", "party2", "party3", "party4" }

    addon.WoW.Api.UnitGroupRolesAssigned = function(x)
        return x == "party3" and "TANK" or "DAMAGER"
    end

    local macroText = [[
        #showtooltip
        #framesort Tank
        /cast [@none] Spell;
    ]]
    local expected = [[
        #showtooltip
        #framesort Tank
        /cast [@party3] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_healer()
    local units = { "player", "party1", "party2", "party3", "party4" }

    addon.WoW.Api.UnitGroupRolesAssigned = function(x)
        return x == "party1" and "HEALER" or "DAMAGER"
    end

    local macroText = [[
        #showtooltip
        #framesort Healer
        /cast [@none] Spell;
    ]]
    local expected = [[
        #showtooltip
        #framesort Healer
        /cast [@party1] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #framesort HEALER
        /cast [@none] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort HEALER
        /cast [@party1] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #framesort healer, frame1
        /cast [@none,exists][@none,exists] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort healer, frame1
        /cast [@party1,exists][@player,exists] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #framesort healer
        /cast [@none,exists][] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort healer
        /cast [@party1,exists][] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_dps()
    local units = { "player", "party4", "party3", "party2", "party1" }

    addon.WoW.Api.UnitGroupRolesAssigned = function(x)
        if x == "party4" then
            return "DAMAGER"
        end

        return "NONE"
    end

    local macroText = [[
        #showtooltip
        #framesort DPS
        /cast [@none] Spell;
    ]]
    local expected = [[
        #showtooltip
        #framesort DPS
        /cast [@party4] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #framesort Dps
        /cast [@none] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort Dps
        /cast [@party4] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #framesort dps, frame1
        /cast [@none,exists][@none,exists] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort dps, frame1
        /cast [@party4,exists][@player,exists] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_other_dps()
    local units = { "player", "party1", "party2" }

    addon.WoW.Api.UnitGroupRolesAssigned = function(x)
        if x == "party1" then
            return "HEALER"
        end

        return "DAMAGER"
    end

    local macroText = [[
        #showtooltip
        #framesort OtherDPS
        /cast [@none] Spell;
    ]]
    local expected = [[
        #showtooltip
        #framesort OtherDPS
        /cast [@party2] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_target()
    local units = { "player", "party1", "party2" }

    addon.WoW.Api.UnitGroupRolesAssigned = function(x)
        if x == "party1" then
            return "HEALER"
        end

        return "DAMAGER"
    end

    local macroText = [[
        #showtooltip
        #framesort Healer, Target
        /cast [@none,exists][@b] Spell;
    ]]
    local expected = [[
        #showtooltip
        #framesort Healer, Target
        /cast [@party1,exists][@Target] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_focus()
    local units = { "player", "party1", "party2" }

    addon.WoW.Api.UnitGroupRolesAssigned = function(x)
        if x == "party1" then
            return "HEALER"
        end

        return "DAMAGER"
    end

    local macroText = [[
        #showtooltip
        #framesort Focus, Target
        /cast [mod:shift,@a][@b] Spell;
    ]]
    local expected = [[
        #showtooltip
        #framesort Focus, Target
        /cast [mod:shift,@Focus][@Target] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_tank_n()
    local units = { "player", "party1", "party2", "party3", "party4" }

    addon.WoW.Api.UnitGroupRolesAssigned = function(_)
        return "TANK"
    end

    local macroText = [[
        #showtooltip
        #framesort Tank
        /cast [@none] Spell;
    ]]
    local expected = [[
        #showtooltip
        #framesort Tank
        /cast [@player] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #framesort Tank1
        /cast [@none] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort Tank1
        /cast [@player] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #framesort Tank2
        /cast [@none] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort Tank2
        /cast [@party1] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #framesort Tank5
        /cast [@none] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort Tank5
        /cast [@party4] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_healer_n()
    local units = { "player", "party1", "party2", "party3", "party4" }

    addon.WoW.Api.UnitGroupRolesAssigned = function(_)
        return "HEALER"
    end

    local macroText = [[
        #showtooltip
        #framesort Healer1, Healer3, Healer2
        /cast [@a,exists][@b,exists][@c,exists] Spell;
    ]]
    local expected = [[
        #showtooltip
        #framesort Healer1, Healer3, Healer2
        /cast [@player,exists][@party2,exists][@party1,exists] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_role_multi_n()
    local units = { "player", "party1", "party2", "party3", "party4" }

    addon.WoW.Api.UnitGroupRolesAssigned = function(x)
        if x == "party1" then
            return "TANK"
        end
        if x == "party3" then
            return "HEALER"
        end

        return "DAMAGER"
    end

    local macroText = [[
        #showtooltip
        #framesort DPS2
        /cast [@a] Spell;
    ]]
    local expected = [[
        #showtooltip
        #framesort DPS2
        /cast [@party2] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_role_dps()
    local units = { "player", "party1", "party2", "party3", "party4" }

    addon.WoW.Api.UnitGroupRolesAssigned = function(_)
        return "DAMAGER"
    end

    local macroText = [[
        #showtooltip
        #framesort DPS
        /cast [@none] Spell;
    ]]
    local expected = [[
        #showtooltip
        #framesort DPS
        /cast [@player] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #framesort DPS3
        /cast [@none] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort DPS3
        /cast [@party2] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_specific()
    local units = { "player", "party1", "party2", "party3", "party4" }

    local macroText = [[
        #showtooltip
        #framesort arena1, arena2, arena3
        /cast [mod:ctrl,@a][mod:shift,@b][@c] Spell;
    ]]
    local expected = [[
        #showtooltip
        #framesort arena1, arena2, arena3
        /cast [mod:ctrl,@arena1][mod:shift,@arena2][@arena3] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #framesort playername, party1
        /cast [mod:ctrl,@playername][mod:shift,@party1][@nochange] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort playername, party1
        /cast [mod:ctrl,@playername][mod:shift,@party1][@nochange] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_arena_3v3()
    local units = { "arena1", "arena2", "arena3" }

    addon.WoW.Api.GetArenaOpponentSpec = function(i)
        return i
    end
    addon.WoW.Api.GetNumArenaOpponentSpecs = function()
        return 3
    end
    addon.WoW.Api.GetSpecializationInfoByID = function(i)
        local role = ""
        if i == 2 then
            role = "HEALER"
        else
            role = "DAMAGER"
        end

        return nil, nil, nil, nil, role, nil, nil
    end

    local macroText = [[
        #showtooltip
        #framesort EnemyHealer EnemyDPS1 enemydps2
        /cast [@a, exists][@b, exists][@c] Spell
    ]]
    local expected = [[
        #showtooltip
        #framesort EnemyHealer EnemyDPS1 enemydps2
        /cast [@arena2, exists][@arena1, exists][@arena3] Spell
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_arena_5v5()
    local units = { "arena1", "arena2", "arena3", "arena4", "arena5" }

    -- 5v5
    addon.WoW.Api.GetNumArenaOpponentSpecs = function()
        return 5
    end
    addon.WoW.Api.GetArenaOpponentSpec = function(i)
        return i
    end
    addon.WoW.Api.GetSpecializationInfoByID = function(i)
        local role = ""
        if i == 1 then
            role = "TANK"
        elseif i == 2 then
            role = "HEALER"
        else
            role = "DAMAGER"
        end

        return nil, nil, nil, nil, role, nil, nil
    end

    local macroText = [[
        #showtooltip
        #framesort EnemyHealer, EnemyTank
        /cast [@a, exists][@b, exists] Spell
    ]]
    local expected = [[
        #showtooltip
        #framesort EnemyHealer, EnemyTank
        /cast [@arena2, exists][@arena1, exists] Spell
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_multiline()
    local units = { "player", "party1", "party2" }

    local macroText = [[
        #showtooltip
        #framesort Frame1, Frame2, Frame3
        /cast [@a,exists] Spell;
        /cast [@b,exists] Spell;
        /cast [@c,exists] Spell;
    ]]
    local expected = [[
        #showtooltip
        #framesort Frame1, Frame2, Frame3
        /cast [@player,exists] Spell;
        /cast [@party1,exists] Spell;
        /cast [@party2,exists] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #framesort Frame1, Frame2, Frame3
        /cast [@a,exists] Spell;

        #comment
        /cast [@b,exists] Spell;

        # asdf

        /cast [@c,exists] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort Frame1, Frame2, Frame3
        /cast [@player,exists] Spell;

        #comment
        /cast [@party1,exists] Spell;

        # asdf

        /cast [@party2,exists] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_long_syntax()
    local units = { "player", "party1", "party2" }

    local macroText = [[
        #showtooltip
        #framesort Frame1, Frame2, Frame3
        /cast [target=a,exists] Spell;
        /cast [target=b,exists] Spell;
        /cast [target=something,exists] Spell;
    ]]
    local expected = [[
        #showtooltip
        #framesort Frame1, Frame2, Frame3
        /cast [target=player,exists] Spell;
        /cast [target=party1,exists] Spell;
        /cast [target=party2,exists] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

function M:test_syntax_combination()
    local units = { "player", "party1", "party2" }

    local macroText = [[
        #showtooltip
        #framesort Frame1, Frame2, Frame3
        /cast [target=a,exists] Spell;
        /cast [@b,exists] Spell;
        /cast [target=something,exists] Spell;
    ]]
    local expected = [[
        #showtooltip
        #framesort Frame1, Frame2, Frame3
        /cast [target=player,exists] Spell;
        /cast [@party1,exists] Spell;
        /cast [target=party2,exists] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #framesort Frame1, Frame2, Frame3, player
        /cast [target=a, @b, @c, target=@d] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort Frame1, Frame2, Frame3, player
        /cast [target=player, @party1, @party2, target=@player] Spell;
    ]]

    assertEquals(fsMacro:GetNewBody(macroText, units), expected)
end

return M
