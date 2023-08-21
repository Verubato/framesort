---@type AddonMock
local addon = require("Addon")
local frame = require("Mock\\Frame")
local wow = addon.WoW.Api
local provider = addon.Providers.Test
local M = {}

function M:setup()
    addon:InitDB()
    addon.Providers:Init()
    addon.Scheduling.Scheduler:Init()
    addon.Modules.Macro:Init()

    local partyContainer = frame:New()
    local player = frame:New("Frame", nil, partyContainer, nil)
    player.State.Position.Top = 300
    player.unit = "player"

    local p1 = frame:New("Frame", nil, partyContainer, nil)
    p1.State.Position.Top = 100
    p1.unit = "party1"

    local p2 = frame:New("Frame", nil, partyContainer, nil)
    p2.State.Position.Top = 200
    p2.unit = "party2"

    provider.State.PartyFrames = {
        player,
        p1,
        p2,
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
    wow:FireEvent(wow.Events.PLAYER_REGEN_ENABLED)

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
    wow:FireEvent(wow.Events.PLAYER_REGEN_ENABLED)

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
