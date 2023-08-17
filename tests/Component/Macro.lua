local addon = require("Addon")
local wow = addon.WoW
local provider = addon.Frame.Providers.Test
local M = {}

function M:setup()
    addon:InitSavedVars()
    addon:InitScheduler()
    addon:InitMacros()

    local framesParent = {}
    provider.Frames = {
        {
            unit = "player",
            IsVisible = function()
                return true
            end,
            GetTop = function()
                return 300
            end,
            GetLeft = function()
                return 0
            end,
            GetPoint = function()
                return "TOPLEFT", framesParent, "TOPLEFT", 0, 300
            end,
        },
        {
            unit = "party1",
            IsVisible = function()
                return true
            end,
            GetTop = function()
                return 200
            end,
            GetLeft = function()
                return 0
            end,
            GetPoint = function()
                return "TOPLEFT", framesParent, "TOPLEFT", 0, 200
            end,
        },
        {
            unit = "party2",
            IsVisible = function()
                return true
            end,
            GetTop = function()
                return 100
            end,
            GetLeft = function()
                return 0
            end,
            GetPoint = function()
                return "TOPLEFT", framesParent, "TOPLEFT", 0, 100
            end,
        },
    }
end

function M:teardown()
    addon:Reset()
end

function M:test_macro_updates_on_provider_callback()
    local macro = [[
    #FrameSort Frame1
    /cast [@placeholder] Spell
    ]]

    wow:LoadMacro(1, "Test", "Test", macro)

    provider:FireCallbacks()

    assertEquals(
        wow.State.Macros[1].Body,
        [[
    #FrameSort Frame1
    /cast [@player] Spell
    ]]
    )
end

function M:test_macro_updates_after_user_edits()
    local macro = [[
    #FrameSort Frame1
    /cast [@placeholder] Spell
    ]]

    wow:LoadMacro(1, "Test", "Test", macro)
    wow:InvokeSecureHooks("EditMacro", 1)

    -- should have changed now that combat dropped
    assertEquals(
        wow.State.Macros[1].Body,
        [[
    #FrameSort Frame1
    /cast [@player] Spell
    ]]
    )
end

function M:test_macro_updates_for_provider_after_combat()
    local macro = [[
    #FrameSort Frame1
    /cast [@placeholder] Spell
    ]]

    wow:LoadMacro(1, "Test", "Test", macro)

    wow.State.MockInCombat = true
    provider:FireCallbacks()

    -- should not have changed as we're in combat
    assertEquals(macro, wow.State.Macros[1].Body)

    wow.State.MockInCombat = false
    wow:FireEvent(addon.Events.PLAYER_REGEN_ENABLED)

    -- should have changed now that combat dropped
    assertEquals(
        wow.State.Macros[1].Body,
        [[
    #FrameSort Frame1
    /cast [@player] Spell
    ]]
    )
end

function M:test_macro_updates_for_hook_after_combat()
    local macro = [[
    #FrameSort Frame1
    /cast [@placeholder] Spell
    ]]

    wow:LoadMacro(1, "Test", "Test", macro)

    wow.State.MockInCombat = true
    wow:InvokeSecureHooks("EditMacro", 1)

    -- should not have changed as we're in combat
    assertEquals(macro, wow.State.Macros[1].Body)

    wow.State.MockInCombat = false
    wow:FireEvent(addon.Events.PLAYER_REGEN_ENABLED)

    -- should have changed now that combat dropped
    assertEquals(
        wow.State.Macros[1].Body,
        [[
    #FrameSort Frame1
    /cast [@player] Spell
    ]]
    )
end

function M:test_macro_updates_are_efficient()
    local fsMacro = [[
    #FrameSort Frame1
    /cast [@placeholder] Spell
    ]]
    local notfsMacro = [[
    /cast [@placeholder] Spell
    ]]

    wow:LoadMacro(1, "Test", "Test", fsMacro)
    wow:LoadMacro(2, "Test2", "Test2", notfsMacro)

    local timesToInspect = 5
    for _ = 1, timesToInspect do
        provider:FireCallbacks()
    end

    assertEquals(wow.State.Macros[1].TimesRetrieved, timesToInspect)

    -- should have only inspected the non-fs macro once
    assertEquals(wow.State.Macros[2].TimesRetrieved, 1)
end

return M
