local deps = {
    "Util\\Enumerable.lua",
    "Util\\Macro.lua",
}

local addon = {}
for _, fileName in ipairs(deps) do
    local module = loadfile("..\\src\\" .. fileName)
    if module == nil then
        error("Failed to load " .. fileName)
    end
    module("UnitTest", addon)
end

local M = {}
local macro = addon.Macro

function M:testSetup()
    IsInGroup = function()
        return true
    end
end

function M:test_is_framesort_macro()
    assertEquals(
        macro:IsFrameSortMacro([[
        #framesort
        ]]),
        true
    )

    assertEquals(
        macro:IsFrameSortMacro([[
        #showtooltip
        #framesort frame1
        /cast [help, @a] Spell; [harm, @a] Spell2;
        ]]),
        true
    )

    assertEquals(
        macro:IsFrameSortMacro([[
        # FrameSort frame1
        /cast [help, @a] Spell; [harm, @a] Spell2;
        ]]),
        true
    )

    assertEquals(
        macro:IsFrameSortMacro([[
        # framesort Frame2
        /cast [help, @a] Spell; [harm, @a] Spell2;
        ]]),
        true
    )

    assertEquals(
        macro:IsFrameSortMacro([[
        #FrameSort: Frame1, Frame2
        /cast [help, @a] Spell; [harm, @a] Spell2;
        ]]),
        true
    )
end

function M:test_is_not_framesort_macro()
    assertEquals(
        macro:IsFrameSortMacro([[
        #showtooltip
        /cast Moonfire;
        ]]),
        false
    )

    assertEquals(
        macro:IsFrameSortMacro([[
        #showtooltip
        /cast [help, @a] Spell; [harm, @a] Spell2;
        ]]),
        false
    )

    assertEquals(
        macro:IsFrameSortMacro([[
        /cast [help, @a] Spell; [harm, @a] Spell2;
        ]]),
        false
    )

    assertEquals(
        macro:IsFrameSortMacro([[
        /cast [help, @a] Spell; [harm, @a] Spell2;
        ]]),
        false
    )
end

function M:test_party()
    local units = { "party2", "party4", "party1", "party2", "player" }
    local macroText = [[
        #showtooltip
        #FrameSort Frame1
        /cast [@previous] Spell
    ]]
    local expected = [[
        #showtooltip
        #FrameSort Frame1
        /cast [@party2] Spell
    ]]

    assertEquals(macro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #FrameSort Frame1
        /cast [@] Spell
    ]]
    expected = [[
        #showtooltip
        #FrameSort Frame1
        /cast [@party2] Spell
    ]]

    assertEquals(macro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        # framesort Frame1 frame2
        /cast [@a] Spell; [mod:shift, @b] Spell;
    ]]
    expected = [[
        #showtooltip
        # framesort Frame1 frame2
        /cast [@party2] Spell; [mod:shift, @party4] Spell;
    ]]

    assertEquals(macro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        # framesort Frame1 frame2, frame3:frame4, frame5
        /cast [@a,exists][@,exists][@player,exists][@previousname][@] Spell;
    ]]
    expected = [[
        #showtooltip
        # framesort Frame1 frame2, frame3:frame4, frame5
        /cast [@party2,exists][@party4,exists][@party1,exists][@party2][@player] Spell;
    ]]

    assertEquals(macro:GetNewBody(macroText, units), expected)

    macroText = [[
        #framesort frame1
        /cmd [@frame1]
    ]]
    expected = [[
        #framesort frame1
        /cmd [@party2]
    ]]

    assertEquals(macro:GetNewBody(macroText, units), expected)
end

function M:test_raid()
    local units = { "raid3", "raid11", "raid17" }
    local macroText = [[
        #showtooltip
        #framesort frame3, frame2, frame1
        /cast [@none,exists][@none,exists][@none,exists] Spell;
    ]]
    local expected = [[
        #showtooltip
        #framesort frame3, frame2, frame1
        /cast [@raid17,exists][@raid11,exists][@raid3,exists] Spell;
    ]]

    assertEquals(macro:GetNewBody(macroText, units), expected)
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

    assertEquals(macro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #framesort Player
        /cast [@none] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort Player
        /cast [@player] Spell;
    ]]

    assertEquals(macro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #framesort frame1, player, frame2
        /cast [@none,exists][@none,exists][@none,exists] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort frame1, player, frame2
        /cast [@player,exists][@player,exists][@party1,exists] Spell;
    ]]

    assertEquals(macro:GetNewBody(macroText, units), expected)
end

function M:test_tank()
    local units = { "player", "party1", "party2", "party3", "party4" }

    UnitGroupRolesAssigned = function(x)
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

    assertEquals(macro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #framesort TANK
        /cast [@none] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort TANK
        /cast [@party3] Spell;
    ]]

    assertEquals(macro:GetNewBody(macroText, units), expected)

    macroText = [[
        #showtooltip
        #framesort tank, frame1
        /cast [@none,exists][@none,exists] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort tank, frame1
        /cast [@party3,exists][@player,exists] Spell;
    ]]

    assertEquals(macro:GetNewBody(macroText, units), expected)
end

function M:test_role_n()
    local units = { "player", "party1", "party2", "party3", "party4" }

    UnitGroupRolesAssigned = function(x)
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

    assertEquals(macro:GetNewBody(macroText, units), expected)

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

    assertEquals(macro:GetNewBody(macroText, units), expected)

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

    assertEquals(macro:GetNewBody(macroText, units), expected)

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

    assertEquals(macro:GetNewBody(macroText, units), expected)

    UnitGroupRolesAssigned = function(x)
        return "DAMAGER"
    end

    macroText = [[
        #showtooltip
        #framesort DPS
        /cast [@none] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort DPS
        /cast [@player] Spell;
    ]]

    assertEquals(macro:GetNewBody(macroText, units), expected)

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

    assertEquals(macro:GetNewBody(macroText, units), expected)

    UnitGroupRolesAssigned = function(x)
        return "HEALER"
    end

    macroText = [[
        #showtooltip
        #framesort Healer1, Healer3, Healer2
        /cast [@a,exists][@b,exists][@c,exists] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort Healer1, Healer3, Healer2
        /cast [@player,exists][@party2,exists][@party1,exists] Spell;
    ]]

    assertEquals(macro:GetNewBody(macroText, units), expected)

    UnitGroupRolesAssigned = function(x)
        if x == "party1" then
            return "TANK"
        end
        if x == "party3" then
            return "HEALER"
        end

        return "DAMAGER"
    end

    macroText = [[
        #showtooltip
        #framesort DPS2
        /cast [@a] Spell;
    ]]
    expected = [[
        #showtooltip
        #framesort DPS2
        /cast [@party2] Spell;
    ]]

    assertEquals(macro:GetNewBody(macroText, units), expected)
end

function M:test_healer()
    local units = { "player", "party1", "party2", "party3", "party4" }

    UnitGroupRolesAssigned = function(x)
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

    assertEquals(macro:GetNewBody(macroText, units), expected)

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

    assertEquals(macro:GetNewBody(macroText, units), expected)

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

    assertEquals(macro:GetNewBody(macroText, units), expected)
end

function M:test_dps()
    local units = { "player", "party4", "party3", "party2", "party1" }

    UnitGroupRolesAssigned = function(x)
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

    assertEquals(macro:GetNewBody(macroText, units), expected)

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

    assertEquals(macro:GetNewBody(macroText, units), expected)

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

    assertEquals(macro:GetNewBody(macroText, units), expected)
end

return M
