local addon = require("Addon")
local frame = require("Mock\\Frame")
local provider = addon.Providers.Test
local realBlizzardProvider = addon.Providers.Blizzard
local M = {}

function M:setup()
    addon.Providers.Blizzard = provider
    addon:InitDB()
    addon.Api:Init()

    local partyContainer = frame:New()
    local player = frame:New("Frame", nil, partyContainer, nil)
    player.State.Position.Top = 300
    player.unit = "player"

    local p1 = frame:New("Frame", nil, partyContainer, nil)
    p1.State.Position.Top = 100
    p1.unit = "party1"

    local p2 = frame:New("Frame", nil, partyContainer, nil)
    p2.State.Position.Top = 200
    p2.unit = "party2"

    provider.State.PartyFrames = {
        player,
        p1,
        p2,
    }

    provider.State.RaidFrames = {
        player,
        p1,
        p2,
    }

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

    assertEquals(#frames, 3)
end

function M:test_get_raid_frames()
    local frames = FrameSortApi.v1.Sorting:GetRaidFrames()

    assertEquals(#frames, 3)
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
