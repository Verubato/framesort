---@type AddonMock
local addon = require("Mock\\Addon")
local frame = require("Mock\\Frame")
local wow = addon.WoW.Api
local provider = addon.Providers.Test
local realBlizzardProvider = addon.Providers.Blizzard
local fsFrame = addon.WoW.Frame
local fsEnumerable = addon.Collections.Enumerable
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
    addon:Reset()
    addon.Providers.Blizzard = realBlizzardProvider
end

function M:test_player_hides_on_provider_callback()
    assert(player)

    local config = addon.DB.Options.Sorting.World
    config.Enabled = true
    config.PlayerSortMode = "Hidden"

    provider:FireCallbacks()

    local driver = fsEnumerable
        :From(wow.State.AttributeDrivers)
        :Where(function(x) return x.Frame == player end)
        :First()

    assert(driver)

    assertEquals(driver.Attribute, "state-visibility")
    assertEquals(driver.Conditional, "hide")
end

function M:test_player_shows_on_provider_callback()
    assert(player)

    player.State.Visible = false

    local config = addon.DB.Options.Sorting.World
    config.Enabled = true
    config.PlayerSortMode = "Top"

    provider:FireCallbacks()

    local driver = fsEnumerable
        :From(wow.State.AttributeDrivers)
        :Where(function(x) return x.Frame == player end)
        :First()

    assert(driver)

    assertEquals(driver.Attribute, "state-visibility")
    assertEquals(driver.Conditional, "show")
end

function M:test_player_hides_after_combat()
    assert(player)

    local config = addon.DB.Options.Sorting.World
    config.Enabled = true
    config.PlayerSortMode = "Hidden"
    wow.State.MockInCombat = true

    provider:FireCallbacks()

    wow.State.MockInCombat = false
    wow:FireEvent(wow.Events.PLAYER_REGEN_ENABLED)

    local driver = fsEnumerable
        :From(wow.State.AttributeDrivers)
        :Where(function(x) return x.Frame == player end)
        :First()

    assert(driver)

    assertEquals(driver.Attribute, "state-visibility")
    assertEquals(driver.Conditional, "hide")
end

function M:test_player_shows_after_combat()
    assert(player)

    player.State.Visible = false

    local config = addon.DB.Options.Sorting.World
    config.Enabled = true
    config.PlayerSortMode = "Top"
    wow.State.MockInCombat = true

    provider:FireCallbacks()

    wow.State.MockInCombat = false
    wow:FireEvent(wow.Events.PLAYER_REGEN_ENABLED)

    local driver = fsEnumerable
        :From(wow.State.AttributeDrivers)
        :Where(function(x) return x.Frame == player end)
        :First()

    assert(driver)

    assertEquals(driver.Attribute, "state-visibility")
    assertEquals(driver.Conditional, "show")
end

return M
