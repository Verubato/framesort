---@type AddonMock
local addon = require("Addon")
local wow = addon.WoW.Api
local provider = addon.Providers.Test
local realBlizzardProvider = addon.Providers.Blizzard
local M = {}

function M:setup()
    addon.Providers.Blizzard = provider

    addon:InitDB()
    addon.Providers:Init()
    addon.Scheduling.Scheduler:Init()
    addon.Modules.HidePlayer:Init()
end

function M:teardown()
    addon:Reset()

    addon.Providers.Blizzard = realBlizzardProvider
    addon.DB.Options.World.Enabled = addon.Configuration.Defaults.World.Enabled
    addon.DB.Options.World.PlayerSortMode = addon.Configuration.Defaults.World.PlayerSortMode
end

function M:test_player_hides_on_provider_callback()
    local framesParent = {}
    provider.State.PartyFrames = {
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

    addon.DB.Options.World.Enabled = true
    addon.DB.Options.World.PlayerSortMode = "Hidden"

    provider:FireCallbacks()

    assertEquals(#wow.State.AttributeDrivers, 1)

    local driver = wow.State.AttributeDrivers[1]
    assertEquals(driver.Frame, provider.State.PartyFrames[1])
    assertEquals(driver.Attribute, "state-visibility")
    assertEquals(driver.Conditional, "hide")
end

function M:test_player_shows_on_provider_callback()
    local framesParent = {}
    provider.State.PartyFrames = {
        {
            unit = "player",
            IsVisible = function()
                return false
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

    addon.DB.Options.World.Enabled = true
    addon.DB.Options.World.PlayerSortMode = "Top"

    provider:FireCallbacks()

    assertEquals(#wow.State.AttributeDrivers, 1)

    local driver = wow.State.AttributeDrivers[1]
    assertEquals(driver.Frame, provider.State.PartyFrames[1])
    assertEquals(driver.Attribute, "state-visibility")
    assertEquals(driver.Conditional, "show")
end

function M:test_player_hides_after_combat()
    local framesParent = {}
    provider.State.PartyFrames = {
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

    addon.DB.Options.World.Enabled = true
    addon.DB.Options.World.PlayerSortMode = "Hidden"
    wow.State.MockInCombat = true

    provider:FireCallbacks()

    assertEquals(#wow.State.AttributeDrivers, 0)

    wow.State.MockInCombat = false
    wow:FireEvent(wow.Events.PLAYER_REGEN_ENABLED)

    local driver = wow.State.AttributeDrivers[1]
    assertEquals(driver.Frame, provider.State.PartyFrames[1])
    assertEquals(driver.Attribute, "state-visibility")
    assertEquals(driver.Conditional, "hide")
end

function M:test_player_shows_after_combat()
    local framesParent = {}
    provider.State.PartyFrames = {
        {
            unit = "player",
            IsVisible = function()
                return false
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
    assertEquals(driver.Frame, provider.State.PartyFrames[1])
    assertEquals(driver.Attribute, "state-visibility")
    assertEquals(driver.Conditional, "show")
end

return M
