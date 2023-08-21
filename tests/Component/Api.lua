local addon = require("Addon")
local provider = addon.Providers.Test
local fsConfig = addon.Configuration
local realBlizzardProvider = addon.Providers.Blizzard
local M = {}

function M:setup()
    addon.Providers.Blizzard = provider
    addon:InitDB()
    addon.Api:Init()
    addon.Providers:Init()

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
                return 100
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
                return 200
            end,
            GetLeft = function()
                return 0
            end,
            GetPoint = function()
                return "TOPLEFT", framesParent, "TOPLEFT", 0, 100
            end,
        },
    }

    local raidFramesParent = {}
    provider.State.RaidFrames = {
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
                return "TOPLEFT", raidFramesParent, "TOPLEFT", 0, 300
            end,
        },
        {
            unit = "party1",
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
                return "TOPLEFT", raidFramesParent, "TOPLEFT", 0, 200
            end,
        },
        {
            unit = "party2",
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
                return "TOPLEFT", raidFramesParent, "TOPLEFT", 0, 100
            end,
        },
    }

end

function M:teardown()
    addon.Providers.Blizzard = realBlizzardProvider
    addon.DB.Options.Arena.PlayerSortMode = fsConfig.Defaults.PlayerSortMode
    addon.DB.Options.Arena.GroupSortMode = fsConfig.Defaults.GroupSortMode
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
