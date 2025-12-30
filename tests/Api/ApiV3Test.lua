---@type Addon
local addon
local M = {}
local partyUnitsCount = 3
local raidUnitsCount = 6
local arenaUnitsCount = 3

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    local frameMock = require("TestHarness\\FrameMock")
    local providerFactory = require("TestHarness\\ProviderFactory")

    addon = addonFactory:Create()
    addon.Api:Init()
    addon.Modules:Init()

    local fsFrame = addon.WoW.Frame
    local provider = providerFactory:Create()

    addon.Providers.Test = provider
    addon.Providers.All[#addon.Providers.All + 1] = provider

    local party = fsFrame:GetContainer(provider, fsFrame.ContainerType.Party)

    assert(party)

    local partyContainer = party.Frame

    for i = 1, partyUnitsCount do
        local unit = frameMock:New("Frame", nil, partyContainer, nil)
        unit.unit = "party" .. i
    end

    local raid = fsFrame:GetContainer(provider, fsFrame.ContainerType.Raid)

    assert(raid)

    local raidContainer = raid.Frame

    for i = 1, raidUnitsCount do
        local unit = frameMock:New("Frame", nil, raidContainer, nil)
        unit.unit = "raid" .. i
    end

    local arena = fsFrame:GetContainer(provider, fsFrame.ContainerType.EnemyArena)

    assert(arena)

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
    addon.WoW.Capabilities.HasEnemySpecSupport = function()
        return true
    end
    addon.WoW.Capabilities.HasSpecializations = function()
        return true
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

function M:test_error_doesnt_propagate()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    local fsSort = addon.Modules.Sorting

    -- corrupt some stuff to cause an error
    ---@diagnostic disable-next-line: duplicate-set-field
    fsSort.RegisterPostSortCallback = function()
        assert(false, "Swallowed error")
    end

    local result = v3.Sorting:RegisterPostSortCallback(function() end)

    assertEquals(result, false)
end

function M:test_get_party_frames()
    local data = FrameSortApi.v3.Sorting:GetPartyFrames()
    local frames = data["Test"]

    assertEquals(#frames, partyUnitsCount)
end

function M:test_get_raid_frames()
    local data = FrameSortApi.v3.Sorting:GetRaidFrames()
    local frames = data["Test"]

    assertEquals(#frames, raidUnitsCount)
end

function M:test_get_arena_frames()
    local data = FrameSortApi.v3.Sorting:GetArenaFrames()
    local frames = data["Test"]

    assertEquals(#frames, arenaUnitsCount)
end

function M:test_get_friendly_units()
    local units = FrameSortApi.v3.Sorting:GetFriendlyUnits()

    assertEquals(#units, partyUnitsCount)
end

function M:test_get_enemy_units()
    local config = addon.DB.Options.Sorting.EnemyArena

    config.Enabled = true

    local units = FrameSortApi.v3.Sorting:GetEnemyUnits()

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

    assertEquals(FrameSortApi.v3.Options:GetPlayerSortMode("Arena - 2v2"), config.Arena.Twos.PlayerSortMode)
    assertEquals(FrameSortApi.v3.Options:GetPlayerSortMode("Arena - Default"), config.Arena.Default.PlayerSortMode)
    assertEquals(FrameSortApi.v3.Options:GetPlayerSortMode("Dungeon"), config.Dungeon.PlayerSortMode)
    assertEquals(FrameSortApi.v3.Options:GetPlayerSortMode("Raid"), config.Raid.PlayerSortMode)
    assertEquals(FrameSortApi.v3.Options:GetPlayerSortMode("World"), config.World.PlayerSortMode)

    assertEquals(FrameSortApi.v3.Options:GetGroupSortMode("Arena - 2v2"), config.Arena.Twos.GroupSortMode)
    assertEquals(FrameSortApi.v3.Options:GetGroupSortMode("Arena - Default"), config.Arena.Default.GroupSortMode)
    assertEquals(FrameSortApi.v3.Options:GetGroupSortMode("Dungeon"), config.Dungeon.GroupSortMode)
    assertEquals(FrameSortApi.v3.Options:GetGroupSortMode("Raid"), config.Raid.GroupSortMode)
    assertEquals(FrameSortApi.v3.Options:GetGroupSortMode("World"), config.World.GroupSortMode)

    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(FrameSortApi.v3.Options:GetPlayerSortMode(nil), nil)
    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(FrameSortApi.v3.Options:GetPlayerSortMode("invalid"), nil)

    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(FrameSortApi.v3.Options:GetGroupSortMode(nil), nil)
    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(FrameSortApi.v3.Options:GetGroupSortMode("invalid"), nil)
end

function M:test_set_sort_mode()
    assertEquals(FrameSortApi.v3.Options:SetPlayerSortMode("Arena - 2v2", "Bottom"), true)
    assertEquals(FrameSortApi.v3.Options:SetPlayerSortMode("Arena - Default", "Bottom"), true)
    assertEquals(FrameSortApi.v3.Options:SetPlayerSortMode("Dungeon", "Bottom"), true)
    assertEquals(FrameSortApi.v3.Options:SetPlayerSortMode("Raid", "Bottom"), true)
    assertEquals(FrameSortApi.v3.Options:SetPlayerSortMode("World", "Bottom"), true)

    assertEquals(FrameSortApi.v3.Options:SetGroupSortMode("Arena - 2v2", "Role"), true)
    assertEquals(FrameSortApi.v3.Options:SetGroupSortMode("Arena - Default", "Role"), true)
    assertEquals(FrameSortApi.v3.Options:SetGroupSortMode("Dungeon", "Role"), true)
    assertEquals(FrameSortApi.v3.Options:SetGroupSortMode("Raid", "Role"), true)
    assertEquals(FrameSortApi.v3.Options:SetGroupSortMode("World", "Role"), true)

    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(FrameSortApi.v3.Options:SetPlayerSortMode("Invalid", "Bottom"), false)
    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(FrameSortApi.v3.Options:SetGroupSortMode("Invalid", "Role"), false)

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

function M:test_register_external_frame_provider_nil()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    ---@diagnostic disable-next-line: param-type-mismatch
    local ok = v3.Sorting:RegisterFrameProvider(nil)

    assertEquals(ok, false)
end

function M:test_register_external_frame_provider_invalid_provider_not_added()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    local beforeCount = #addon.Providers.All

    -- Missing required methods (Name, IsVisible)
    local invalidProvider = {
        Enabled = function()
            return true
        end,
    }

    local ok = v3.Sorting:RegisterFrameProvider(invalidProvider)

    assertEquals(ok, false)
    assertEquals(#addon.Providers.All, beforeCount)
end

function M:test_register_external_frame_provider_valid_provider_added_and_marked_external()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    local beforeCount = #addon.Providers.All

    local externalProvider = {
        Enabled = function()
            return true
        end,
        Name = function()
            return "ExternalTest"
        end,
        IsVisible = function()
            return true
        end,
    }

    local ok = v3.Sorting:RegisterFrameProvider(externalProvider)

    assertEquals(ok, true)
    assertEquals(externalProvider.IsExternal, true)
    assertEquals(#addon.Providers.All, beforeCount + 1)
    assertEquals(addon.Providers.All[#addon.Providers.All], externalProvider)
end

function M:test_register_external_frame_provider_error_doesnt_propagate()
    ---@type ApiV3
    local v3 = FrameSortApi.v3

    -- Force an error inside the providers module method to ensure SafeCall swallows it
    ---@diagnostic disable-next-line: duplicate-set-field
    addon.Providers.RegisterFrameProvider = function()
        error("Swallowed error")
    end

    local provider = {
        Enabled = function()
            return true
        end,
        Name = function()
            return "ExternalErrorTest"
        end,
        IsVisible = function()
            return true
        end,
    }

    local ok = v3.Sorting:RegisterFrameProvider(provider)

    assertEquals(ok, false)
end

return M
