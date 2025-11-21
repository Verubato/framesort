---@type Addon
local addon
---@type WowApiMock
local wow
local M = {}

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    local providerFactory = require("TestHarness\\ProviderFactory")
    local frameMock = require("TestHarness\\Frame")

    addon = addonFactory:Create()

    local fsFrame = addon.WoW.Frame
    local provider = providerFactory:Create()

    addon.Providers.Test = provider
    addon.Providers.All[#addon.Providers.All + 1] = provider

    fsFrame = addon.WoW.Frame
    wow = addon.WoW.Api

    addon:InitDB()
    addon.Providers:Init()
    addon.Scheduling.Scheduler:Init()
    addon.Modules:Init()

    local party = fsFrame:GetContainer(provider, fsFrame.ContainerType.Party)
    local partyContainer = party.Frame

    local player = frameMock:New("Frame", nil, partyContainer, nil)
    player.State.Position.Top = 300
    player.unit = "player"

    local p1 = frameMock:New("Frame", nil, partyContainer, nil)
    p1.State.Position.Top = 100
    p1.unit = "party1"

    local p2 = frameMock:New("Frame", nil, partyContainer, nil)
    p2.State.Position.Top = 200
    p2.unit = "party2"
end

function M:test_macro_updates_on_run()
    local macro = [[
    #FrameSort Frame1
    /cast [@placeholder] Spell
    ]]

    wow:LoadMacro(1, "Test", "Test", macro)

    addon.Modules.Macro:Run()

    -- ensure the macro changed
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

    wow:LoadMacro(1, "Test", nil, macro)

    wow.State.MockInCombat = true
    addon.Modules:Run()

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

    wow.State.MockInCombat = true

    wow.EditMacro(1, "Test", "Test", macro)

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

    wow:LoadMacro(1, "Test", nil, fsMacro)
    wow:LoadMacro(2, "Test2", nil, notfsMacro)

    local timesToInspect = 5
    for _ = 0, timesToInspect do
        addon.Modules.Macro:Run()
    end

    assertEquals(wow.State.Macros[1].TimesRetrieved, timesToInspect)

    -- should have only inspected the non-fs macro once
    assertEquals(wow.State.Macros[2].TimesRetrieved, 1)
end

return M
