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

    addon.WoW.Api.GetNumGroupMembers = function()
        return partyUnitsCount
    end
    addon.WoW.Api.IsInInstance = function()
        return true, "arena"
    end
    addon.WoW.Api.GetNumArenaOpponentSpecs = function()
        return arenaUnitsCount
    end
    addon.WoW.Api.UnitIsFriend = function(unit)
        return not unit:match("arena")
    end

    local config = addon.DB.Options.Sorting
    config.World.Enabled = true
    config.Raid.Enabled = true
    config.Arena.Twos.Enabled = true
    config.Arena.Default.Enabled = true
    config.EnemyArena.Enabled = true
    config.Dungeon.Enabled = true
end

function M:test_frame_number_for_unit()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    assertEquals(v3.Frame:FrameNumberForUnit("party1"), 1)
end

return M
