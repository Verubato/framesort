local addon = require("Mock\\Addon")
local frame = require("Mock\\Frame")
local fsFrame = addon.WoW.Frame
local provider = addon.Providers.Test
local realBlizzardProvider = addon.Providers.Blizzard
local M = {}
local partyUnitsCount = 3
local raidUnitsCount = 6

function M:setup()
    addon.Providers.Blizzard = provider
    addon:InitDB()
    addon.Api:Init()

    local party = fsFrame:GetContainer(provider, fsFrame.ContainerType.Party)
    local partyContainer = assert(party).Frame

    assert(partyContainer)

    for i = 1, partyUnitsCount do
        local unit = frame:New("Frame", nil, partyContainer, nil)
        unit.unit = "party" .. i
    end

    local raid = fsFrame:GetContainer(provider, fsFrame.ContainerType.Raid)
    local raidContainer = assert(raid).Frame

    assert(raidContainer)

    for i = 1, raidUnitsCount do
        local unit = frame:New("Frame", nil, raidContainer, nil)
        unit.unit = "raid" .. i
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

function M:teardown()
    addon.Providers.Blizzard = realBlizzardProvider
    addon:Reset()
end

function M:test_get_party_frames()
    local frames = FrameSortApi.v1.Sorting:GetPartyFrames()

    assertEquals(#frames, partyUnitsCount)
end

function M:test_get_raid_frames()
    local frames = FrameSortApi.v1.Sorting:GetRaidFrames()

    assertEquals(#frames, raidUnitsCount)
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

    assertEquals(FrameSortApi.v1.Options:GetPlayerSortMode("Arena"), config.Arena.Default.PlayerSortMode)
    assertEquals(FrameSortApi.v1.Options:GetPlayerSortMode("Arena - 2v2"), config.Arena.Twos.PlayerSortMode)
    assertEquals(FrameSortApi.v1.Options:GetPlayerSortMode("Arena - Default"), config.Arena.Default.PlayerSortMode)
    assertEquals(FrameSortApi.v1.Options:GetPlayerSortMode("Dungeon"), config.Dungeon.PlayerSortMode)
    assertEquals(FrameSortApi.v1.Options:GetPlayerSortMode("Raid"), config.Raid.PlayerSortMode)
    assertEquals(FrameSortApi.v1.Options:GetPlayerSortMode("World"), config.World.PlayerSortMode)

    assertEquals(FrameSortApi.v1.Options:GetGroupSortMode("Arena"), config.Arena.Default.GroupSortMode)
    assertEquals(FrameSortApi.v1.Options:GetGroupSortMode("Arena - 2v2"), config.Arena.Twos.GroupSortMode)
    assertEquals(FrameSortApi.v1.Options:GetGroupSortMode("Arena - Default"), config.Arena.Default.GroupSortMode)
    assertEquals(FrameSortApi.v1.Options:GetGroupSortMode("Dungeon"), config.Dungeon.GroupSortMode)
    assertEquals(FrameSortApi.v1.Options:GetGroupSortMode("Raid"), config.Raid.GroupSortMode)
    assertEquals(FrameSortApi.v1.Options:GetGroupSortMode("World"), config.World.GroupSortMode)
end

function M:test_set_sort_mode()
    FrameSortApi.v1.Options:SetPlayerSortMode("Arena", "Bottom")
    FrameSortApi.v1.Options:SetPlayerSortMode("Dungeon", "Bottom")
    FrameSortApi.v1.Options:SetPlayerSortMode("Raid", "Bottom")
    FrameSortApi.v1.Options:SetPlayerSortMode("World", "Bottom")

    FrameSortApi.v1.Options:SetGroupSortMode("Arena", "Role")
    FrameSortApi.v1.Options:SetGroupSortMode("Dungeon", "Role")
    FrameSortApi.v1.Options:SetGroupSortMode("Raid", "Role")
    FrameSortApi.v1.Options:SetGroupSortMode("World", "Role")

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
