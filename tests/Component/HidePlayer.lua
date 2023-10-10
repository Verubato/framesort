---@type AddonMock
local addon = require("Addon")
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
    addon.Modules.HidePlayer:Init()

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

    addon.DB.Options.World.Enabled = true
    addon.DB.Options.World.PlayerSortMode = "Hidden"

    provider:FireCallbacks()

    assertEquals(#wow.State.AttributeDrivers, 1)

    local driver = wow.State.AttributeDrivers[1]
    assert(driver.Frame == player)
    assertEquals(driver.Attribute, "state-visibility")
    assertEquals(driver.Conditional, "hide")
end

function M:test_player_shows_on_provider_callback()
    assert(player)

    player.State.Visible = false

    addon.DB.Options.World.Enabled = true
    addon.DB.Options.World.PlayerSortMode = "Top"

    provider:FireCallbacks()

    assertEquals(#wow.State.AttributeDrivers, 1)

    local driver = wow.State.AttributeDrivers[1]
    assert(driver.Frame == player)
    assertEquals(driver.Attribute, "state-visibility")
    assertEquals(driver.Conditional, "show")
end

function M:test_player_hides_after_combat()
    assert(player)

    addon.DB.Options.World.Enabled = true
    addon.DB.Options.World.PlayerSortMode = "Hidden"
    wow.State.MockInCombat = true

    provider:FireCallbacks()

    assertEquals(#wow.State.AttributeDrivers, 0)

    wow.State.MockInCombat = false
    wow:FireEvent(wow.Events.PLAYER_REGEN_ENABLED)

    assertEquals(#wow.State.AttributeDrivers, 1)

    local driver = wow.State.AttributeDrivers[1]
    assert(driver.Frame == player)
    assertEquals(driver.Attribute, "state-visibility")
    assertEquals(driver.Conditional, "hide")
end

function M:test_player_shows_after_combat()
    assert(player)

    player.State.Visible = false

    addon.DB.Options.World.Enabled = true
    addon.DB.Options.World.PlayerSortMode = "Top"
    wow.State.MockInCombat = true

    assertEquals(#provider.State.Callbacks, 1)
    provider:FireCallbacks()

    assertEquals(#wow.State.AttributeDrivers, 0)

    wow.State.MockInCombat = false
    wow:FireEvent(wow.Events.PLAYER_REGEN_ENABLED)

    assertEquals(#wow.State.AttributeDrivers, 1)

    local driver = wow.State.AttributeDrivers[1]
    assert(driver.Frame == player)
    assertEquals(driver.Attribute, "state-visibility")
    assertEquals(driver.Conditional, "show")
end

return M
