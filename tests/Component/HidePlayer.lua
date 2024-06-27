---@type AddonMock
local addon = require("Mock\\Addon")
local frame = require("Mock\\Frame")
local wow = addon.WoW.Api
local provider = addon.Providers.Test
local realBlizzardProvider = addon.Providers.Blizzard
local fsFrame = addon.WoW.Frame
local M = {}
local player = nil

function M:setup()
    addon.Providers.Blizzard = provider

    addon:InitDB()
    addon.Providers:Init()
    addon.Scheduling.Scheduler:Init()
    addon.Modules:Init()

    local party = fsFrame:GetContainer(provider, fsFrame.ContainerType.Party)
    local partyContainer = assert(party).Frame

    assert(partyContainer ~= nil)

    player = frame:New("Frame", nil, partyContainer, nil)
    player.State.Position.Top = 300
    player.unit = "player"

    local p1 = frame:New("Frame", nil, partyContainer, nil)
    p1.State.Position.Top = 200
    p1.unit = "party1"

    local p2 = frame:New("Frame", nil, partyContainer, nil)
    p2.State.Position.Top = 100
    p2.unit = "party2"
end

function M:teardown()
    addon.Providers.Blizzard = realBlizzardProvider
    addon:Reset()
end

function M:test_player_shows_and_hides_on_provider_callback()
    assert(player)

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
    assert(player)

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
