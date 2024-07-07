---@type Addon
local addon
local M = {}
local partyUnitsCount = 3
local raidUnitsCount = 6
local arenaUnitsCount = 3

function M:setup()
    local addonFactory = require("Mock\\AddonFactory")
    local frameMock = require("Mock\\Frame")
    local providerFactory = require("Mock\\ProviderFactory")

    addon = addonFactory:Create()
    addon.Api:Init()

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

    local raid = fsFrame:GetContainer(provider, fsFrame.ContainerType.Raid)
    local raidContainer = raid.Frame

    for i = 1, raidUnitsCount do
        local unit = frameMock:New("Frame", nil, raidContainer, nil)
        unit.unit = "raid" .. i
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

    -- disable sorting on config changes
    local config = addon.DB.Options.Sorting
    config.World.Enabled = false
    config.Raid.Enabled = false
    config.Arena.Twos.Enabled = false
    config.Arena.Default.Enabled = false
    config.EnemyArena.Enabled = false
    config.Dungeon.Enabled = false
end

function M:test_get_party_frames()
    local data = FrameSortApi.v2.Sorting:GetPartyFrames()
    local frames = data["Test"]

    assertEquals(#frames, partyUnitsCount)
end

function M:test_get_raid_frames()
    local data = FrameSortApi.v2.Sorting:GetRaidFrames()
    local frames = data["Test"]

    assertEquals(#frames, raidUnitsCount)
end

function M:test_get_arena_frames()
    local data = FrameSortApi.v2.Sorting:GetArenaFrames()
    local frames = data["Test"]

    assertEquals(#frames, arenaUnitsCount)
end

function M:test_get_friendly_units()
    local units = FrameSortApi.v2.Sorting:GetFriendlyUnits()

    assertEquals(#units, partyUnitsCount)
end

function M:test_get_enemy_units()
    local units = FrameSortApi.v2.Sorting:GetEnemyUnits()

    -- times 2 for pets
    assertEquals(#units, arenaUnitsCount * 2)
end

function M:test_get_sort_mode()
    local config = addon.DB.Options.Sorting
    config.Arena.Twos.PlayerSortMode = "ArenaTestPlayer"
    config.Arena.Default.PlayerSortMode = "ArenaTestPlayer"
    config.Dungeon.PlayerSortMode = "DungeonTestPlayer"
    config.Raid.PlayerSortMode = "PlayerTestPlayer"
    config.World.PlayerSortMode = "WorldTestPlayer"

    config.Arena.GroupSortMode = "ArenaTestGroup"
    config.Dungeon.GroupSortMode = "DungeonTestGroup"
    config.Raid.GroupSortMode = "RaidTestGroup"
    config.World.GroupSortMode = "WorldTestGroup"

    assertEquals(FrameSortApi.v2.Options:GetPlayerSortMode("Arena - 2v2"), config.Arena.Twos.PlayerSortMode)
    assertEquals(FrameSortApi.v2.Options:GetPlayerSortMode("Arena - Default"), config.Arena.Default.PlayerSortMode)
    assertEquals(FrameSortApi.v2.Options:GetPlayerSortMode("Dungeon"), config.Dungeon.PlayerSortMode)
    assertEquals(FrameSortApi.v2.Options:GetPlayerSortMode("Raid"), config.Raid.PlayerSortMode)
    assertEquals(FrameSortApi.v2.Options:GetPlayerSortMode("World"), config.World.PlayerSortMode)

    assertEquals(FrameSortApi.v2.Options:GetGroupSortMode("Arena - 2v2"), config.Arena.Twos.GroupSortMode)
    assertEquals(FrameSortApi.v2.Options:GetGroupSortMode("Arena - Default"), config.Arena.Default.GroupSortMode)
    assertEquals(FrameSortApi.v2.Options:GetGroupSortMode("Dungeon"), config.Dungeon.GroupSortMode)
    assertEquals(FrameSortApi.v2.Options:GetGroupSortMode("Raid"), config.Raid.GroupSortMode)
    assertEquals(FrameSortApi.v2.Options:GetGroupSortMode("World"), config.World.GroupSortMode)
end

function M:test_set_sort_mode()
    FrameSortApi.v2.Options:SetPlayerSortMode("Arena - 2v2", "Bottom")
    FrameSortApi.v2.Options:SetPlayerSortMode("Arena - Default", "Bottom")
    FrameSortApi.v2.Options:SetPlayerSortMode("Dungeon", "Bottom")
    FrameSortApi.v2.Options:SetPlayerSortMode("Raid", "Bottom")
    FrameSortApi.v2.Options:SetPlayerSortMode("World", "Bottom")

    FrameSortApi.v2.Options:SetGroupSortMode("Arena - 2v2", "Role")
    FrameSortApi.v2.Options:SetGroupSortMode("Arena - Default", "Role")
    FrameSortApi.v2.Options:SetGroupSortMode("Dungeon", "Role")
    FrameSortApi.v2.Options:SetGroupSortMode("Raid", "Role")
    FrameSortApi.v2.Options:SetGroupSortMode("World", "Role")

    local config = addon.DB.Options.Sorting
    assertEquals(config.Arena.Twos.PlayerSortMode, "Bottom")
    assertEquals(config.Arena.Default.PlayerSortMode, "Bottom")
    assertEquals(config.Dungeon.PlayerSortMode, "Bottom")
    assertEquals(config.Raid.PlayerSortMode, "Bottom")
    assertEquals(config.World.PlayerSortMode, "Bottom")

    assertEquals(config.Arena.Twos.GroupSortMode, "Role")
    assertEquals(config.Arena.Default.GroupSortMode, "Role")
    assertEquals(config.Dungeon.GroupSortMode, "Role")
    assertEquals(config.Raid.GroupSortMode, "Role")
    assertEquals(config.World.GroupSortMode, "Role")
end

return M
