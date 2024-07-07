---@type Addon
local addon
local M = {}
local player
---@type WowApiMock
local wow

function M:setup()
    local addonFactory = require("Mock\\AddonFactory")
    local providerFactory = require("Mock\\ProviderFactory")
    local frameMock = require("Mock\\Frame")

    addon = addonFactory:Create()
    wow = addon.WoW.Api

    local fsFrame = addon.WoW.Frame
    local provider = providerFactory:Create()

    addon.Providers.Test = provider
    addon.Providers.All[#addon.Providers.All + 1] = provider
    addon.Providers.Blizzard = provider

    addon.Modules:Init()

    local party = fsFrame:GetContainer(provider, fsFrame.ContainerType.Party)
    local partyContainer = party.Frame

    player = frameMock:New("Frame", nil, partyContainer, nil)
    player.State.Position.Top = 300
    player.unit = "player"

    local p1 = frameMock:New("Frame", nil, partyContainer, nil)
    p1.State.Position.Top = 200
    p1.unit = "party1"

    local p2 = frameMock:New("Frame", nil, partyContainer, nil)
    p2.State.Position.Top = 100
    p2.unit = "party2"
end

function M:test_player_shows_and_hides_on_provider_callback()
    local provider = addon.Providers.Test
    local config = addon.DB.Options.Sorting.World
    config.Enabled = true

    -- hide the player first
    config.PlayerSortMode = "Hidden"
    provider:FireCallbacks()

    local hideDriver = player.State.AttributeDrivers["state-visibility"]
    assert(hideDriver)

    assertEquals(hideDriver.Attribute, "state-visibility")
    assertEquals(hideDriver.Conditional, "hide")

    config.PlayerSortMode = "Top"
    provider:FireCallbacks()

    local showDriver = player.State.AttributeDrivers["state-visibility"]
    assert(showDriver == nil)
end

function M:test_player_shows_and_hides_after_combat()
    local provider = addon.Providers.Test
    local config = addon.DB.Options.Sorting.World
    config.Enabled = true

    -- hide the player first
    config.PlayerSortMode = "Hidden"
    provider:FireCallbacks()

    local hideDriver = player.State.AttributeDrivers["state-visibility"]
    assert(hideDriver)

    assertEquals(hideDriver.Attribute, "state-visibility")
    assertEquals(hideDriver.Conditional, "hide")

    config.PlayerSortMode = "Hidden"
    wow.State.MockInCombat = true

    provider:FireCallbacks()

    wow.State.MockInCombat = false
    wow:FireEvent(wow.Events.PLAYER_REGEN_ENABLED)

    local showDriver = player.State.AttributeDrivers["state-visibility"]
    assert(showDriver)

    assertEquals(showDriver.Attribute, "state-visibility")
    assertEquals(showDriver.Conditional, "hide")
end

return M
