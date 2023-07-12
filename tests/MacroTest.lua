local deps = {
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

function M:test_get_frame_ids()
    assertEquals(
        macro:GetFrameIds([[
        #showtooltip
        #framesort frame1
        /cast [@a] Spell;
        ]]),
        { 1 }
    )

    assertEquals(
        macro:GetFrameIds([[
        #showtooltip
        #framesort frame1 frame2
        /cast [@a] Spell; [mod:shift, @b] Spell;
        ]]),
        { 1, 2 }
    )

    assertEquals(
        macro:GetFrameIds([[
        #showtooltip
        # FrameSort: frame1, frame2
        /cast [@a] Spell; [mod:shift, @b] Spell;
        ]]),
        { 1, 2 }
    )

    assertEquals(
        macro:GetFrameIds([[
        #showtooltip
        # FrameSort: frame1, frame2, frame3, frame4   frame5
        /cast [@a] Spell; [mod:shift, @b] Spell;
        ]]),
        { 1, 2, 3, 4, 5 }
    )

    assertEquals(
        macro:GetFrameIds([[
        #showtooltip
        # FrameSort = Frame1 Frame4, Frame5
        /cast [@a] Spell; [mod:shift, @b] Spell;
        ]]),
        { 1, 4, 5 }
    )

    assertEquals(
        macro:GetFrameIds([[
        #showtooltip
        # FrameSort = Frame10, Frame44, Frame56
        /cast [@a] Spell; [mod:shift, @b] Spell;
        ]]),
        { 10, 44, 56 }
    )

    assertEquals(
        macro:GetFrameIds([[
        #showtooltip
        # FrameSort = Frame10 Something else 5
        /cast [@a] Spell; [mod:shift, @b] Spell;
        ]]),
        { 10 }
    )

    assertEquals(
        macro:GetFrameIds([[
        #showtooltip
        # FrameSort = Frame1, Frame3
        /cast [@frame2] Spell; [mod:shift, @frame1] Spell;
        ]]),
        { 1, 3 }
    )
end

function M:test_get_new_body()
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

    assertEquals(macro:GetNewBody(macroText, macro:GetFrameIds(macroText), units), expected)

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

    assertEquals(macro:GetNewBody(macroText, macro:GetFrameIds(macroText), units), expected)

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

    assertEquals(macro:GetNewBody(macroText, macro:GetFrameIds(macroText), units), expected)

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

    assertEquals(macro:GetNewBody(macroText, macro:GetFrameIds(macroText), units), expected)

    macroText = [[
        #framesort frame1
        /cmd [@frame1]
    ]]
    expected = [[
        #framesort frame1
        /cmd [@party2]
    ]]

    assertEquals(macro:GetNewBody(macroText, macro:GetFrameIds(macroText), units), expected)
end

return M
