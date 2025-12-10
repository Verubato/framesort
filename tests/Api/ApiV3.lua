---@type Addon
local addon
local M = {}
local partyUnitsCount = 3
local arenaUnitsCount = 3

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    local frameMock = require("TestHarness\\Frame")
    local providerFactory = require("TestHarness\\ProviderFactory")

    addon = addonFactory:Create()
    addon.Api:Init()
    addon.Modules:Init()

    local fsFrame = addon.WoW.Frame
    local provider = providerFactory:Create()

    addon.Providers.Test = provider
    addon.Providers.All[#addon.Providers.All + 1] = provider

    local party = fsFrame:GetContainer(provider, fsFrame.ContainerType.Party)
    local partyContainer = party.Frame

    for i = 1, partyUnitsCount do
        local unit = frameMock:New("Frame", nil, partyContainer, nil)
        unit.unit = "party" .. i
    end

    local arena = fsFrame:GetContainer(provider, fsFrame.ContainerType.EnemyArena)
    local arenaContainer = arena.Frame

    for i = 1, arenaUnitsCount do
        local unit = frameMock:New("Frame", nil, arenaContainer, nil)
        unit.unit = "arena" .. i
    end

    addon.WoW.Api.IsInInstance = function()
        return true, "arena"
    end
    addon.WoW.Api.GetNumGroupMembers = function()
        return partyUnitsCount
    end
    addon.WoW.Api.GetNumArenaOpponentSpecs = function()
        return arenaUnitsCount
    end
    addon.WoW.Api.UnitExists = function(unit)
        local number = tonumber(unit:match("%d+"))

        assert(number and number > 0)

        return number <= 3
    end
end

function M:test_frame_number_for_unit()
    ---@type ApiV3
    local v3 = FrameSortApi.v3
    local config = addon.DB.Options.Sorting

    -- reverse the ordering to ensure we're not lucky
    config.Arena.Default.Enabled = true
    config.Arena.Default.Reverse = true

    config.EnemyArena.Enabled = true
    config.EnemyArena.Reverse = true

    assertEquals(v3.Frame:FrameNumberForUnit("party1"), 3)
    assertEquals(v3.Frame:FrameNumberForUnit("party2"), 2)
    assertEquals(v3.Frame:FrameNumberForUnit("party3"), 1)

    assertEquals(v3.Frame:FrameNumberForUnit("arena1"), 3)
    assertEquals(v3.Frame:FrameNumberForUnit("arena2"), 2)
    assertEquals(v3.Frame:FrameNumberForUnit("arena3"), 1)

    assertEquals(v3.Frame:FrameNumberForUnit(""), nil)
    assertEquals(v3.Frame:FrameNumberForUnit("party99"), nil)
end

return M
