local addon = require("Addon")
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
    addon.DB.Options.World.Enabled = false
    addon.DB.Options.Raid.Enabled = false
    addon.DB.Options.Arena.Enabled = false
    addon.DB.Options.EnemyArena.Enabled = false
    addon.DB.Options.Dungeon.Enabled = false
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
    addon.DB.Options.Arena.PlayerSortMode = "ArenaTestPlayer"
    addon.DB.Options.Dungeon.PlayerSortMode = "DungeonTestPlayer"
    addon.DB.Options.Raid.PlayerSortMode = "PlayerTestPlayer"
    addon.DB.Options.World.PlayerSortMode = "WorldTestPlayer"

    addon.DB.Options.Arena.GroupSortMode = "ArenaTestGroup"
    addon.DB.Options.Dungeon.GroupSortMode = "DungeonTestGroup"
    addon.DB.Options.Raid.GroupSortMode = "RaidTestGroup"
    addon.DB.Options.World.GroupSortMode = "WorldTestGroup"

    assertEquals(FrameSortApi.v1.Options:GetPlayerSortMode("Arena"), addon.DB.Options.Arena.PlayerSortMode)
    assertEquals(FrameSortApi.v1.Options:GetPlayerSortMode("Dungeon"), addon.DB.Options.Dungeon.PlayerSortMode)
    assertEquals(FrameSortApi.v1.Options:GetPlayerSortMode("Raid"), addon.DB.Options.Raid.PlayerSortMode)
    assertEquals(FrameSortApi.v1.Options:GetPlayerSortMode("World"), addon.DB.Options.World.PlayerSortMode)

    assertEquals(FrameSortApi.v1.Options:GetGroupSortMode("Arena"), addon.DB.Options.Arena.GroupSortMode)
    assertEquals(FrameSortApi.v1.Options:GetGroupSortMode("Dungeon"), addon.DB.Options.Dungeon.GroupSortMode)
    assertEquals(FrameSortApi.v1.Options:GetGroupSortMode("Raid"), addon.DB.Options.Raid.GroupSortMode)
    assertEquals(FrameSortApi.v1.Options:GetGroupSortMode("World"), addon.DB.Options.World.GroupSortMode)
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

    assertEquals(addon.DB.Options.Arena.PlayerSortMode, "Bottom")
    assertEquals(addon.DB.Options.Dungeon.PlayerSortMode, "Bottom")
    assertEquals(addon.DB.Options.Raid.PlayerSortMode, "Bottom")
    assertEquals(addon.DB.Options.World.PlayerSortMode, "Bottom")

    assertEquals(addon.DB.Options.Arena.GroupSortMode, "Role")
    assertEquals(addon.DB.Options.Dungeon.GroupSortMode, "Role")
    assertEquals(addon.DB.Options.Raid.GroupSortMode, "Role")
    assertEquals(addon.DB.Options.World.GroupSortMode, "Role")
end

return M
