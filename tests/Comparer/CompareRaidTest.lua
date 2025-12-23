---@diagnostic disable: cast-local-type
---@type Comparer
local fsCompare
---@type Configuration
local fsConfig
---@type Addon
local addon
local M = {}
local playerToken = "raid2"

local function GenerateUnits(count)
    local members = {}

    for i = 1, count do
        members[#members + 1] = "raid" .. i
    end

    return members
end

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    addon = addonFactory:Create()

    fsCompare = addon.Modules.Sorting.Comparer
    fsConfig = addon.Configuration

    addon.DB.Options.Sorting.World.Enabled = true

    local members = GenerateUnits(8)

    addon.WoW.Api.UnitExists = function(unit)
        if unit == "player" then
            return true
        end

        for _, x in pairs(members) do
            if x == unit then
                return true
            end
        end

        return false
    end
    addon.WoW.Api.UnitIsUnit = function(left, right)
        return left == right or (left == playerToken and right == "player")
    end
    addon.WoW.Api.IsInRaid = function()
        return true
    end
end

function M:teardown()
    local world = addon.DB.Options.Sorting.World
    world.Enabled = true
    world.PlayerSortMode = nil
    world.GroupSortMode = nil
    world.Reverse = false

    if fsCompare.InvalidateCache then
        fsCompare:InvalidateCache()
    end

    addon.WoW.Api.UnitExists = nil
    addon.WoW.Api.UnitIsUnit = nil
    addon.WoW.Api.IsInRaid = nil
    addon.WoW.Api.UnitName = nil
    addon.WoW.Api.UnitGroupRolesAssigned = nil
    addon.WoW.Api.UnitClass = nil
    addon.WoW.Api.UnitGUID = nil

    addon = nil
    fsCompare = nil
    fsConfig = nil
end

function M:test_sort_player_top()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = fsConfig.PlayerSortMode.Top
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "raid2", "raid1", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8" })
end

function M:test_sort_player_bottom()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = fsConfig.PlayerSortMode.Bottom
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "raid8", "raid3", "raid4", "raid1", "raid2", "raid7", "raid5", "raid6" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "raid1", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8", "raid2" })
end

function M:test_sort_player_middle()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = fsConfig.PlayerSortMode.Middle
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "raid2", "raid3", "raid4", "raid7", "raid1", "raid5", "raid6" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "raid1", "raid3", "raid4", "raid2", "raid5", "raid6", "raid7" })
end

function M:test_sort_player_hidden()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = fsConfig.PlayerSortMode.Hidden
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    -- player token is raid2, should be pushed to the end
    assertEquals(subject, { "raid1", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8", "raid2" })
end

function M:test_sort_group_sortmode_alphabetical()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = nil
    config.GroupSortMode = fsConfig.GroupSortMode.Alphabetical

    local unitToName = {
        ["raid1"] = "Mona",
        ["raid2"] = "Zed", -- player
        ["raid3"] = "Alice",
        ["raid4"] = "Bob",
        ["raid5"] = "Aaron",
        ["raid6"] = "Xan",
        ["raid7"] = "Kira",
        ["raid8"] = "Nate",
    }

    addon.WoW.Api.UnitName = function(unit)
        return unitToName[unit]
    end

    local subject = { "raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "raid5", "raid3", "raid4", "raid7", "raid1", "raid8", "raid6", "raid2" })
end

function M:test_sort_role_tank_healer_dps()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = nil
    config.GroupSortMode = fsConfig.GroupSortMode.Role

    local unitToRole = {
        ["raid1"] = "DAMAGER",
        -- player
        ["raid2"] = "HEALER",
        ["raid3"] = "DAMAGER",
        ["raid4"] = "TANK",
        ["raid5"] = "DAMAGER",
        ["raid6"] = "DAMAGER",
        ["raid7"] = "HEALER",
        ["raid8"] = "DAMAGER",
    }

    local unitToClass = {
        -- Mage
        ["raid1"] = 8,
        -- Druid
        ["raid2"] = 11,
        -- Death Knight
        ["raid3"] = 6,
        -- Warrior
        ["raid4"] = 1,
        -- Hunter
        ["raid5"] = 3,
        -- Mage
        ["raid6"] = 8,
        -- Priest
        ["raid7"] = 5,
        -- Rogue
        ["raid8"] = 4,
    }

    addon.WoW.Api.UnitGroupRolesAssigned = function(unit)
        return unitToRole[unit]
    end
    addon.WoW.Api.UnitClass = function(unit)
        return "", "", unitToClass[unit]
    end

    local ordering = addon.DB.Options.Sorting.Ordering
    ordering.Tanks = 1
    ordering.Healers = 2
    ordering.Hunters = 3
    ordering.Casters = 4
    ordering.Melee = 5

    local subject = { "raid8", "raid7", "raid6", "raid5", "raid4", "raid3", "raid2", "raid1" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "raid4", "raid7", "raid2", "raid5", "raid1", "raid6", "raid8", "raid3" })
end

function M:test_sort_disabled_returns_nil()
    local config = addon.DB.Options.Sorting.World
    config.Enabled = false
    config.PlayerSortMode = fsConfig.PlayerSortMode.Top
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "raid1", "raid2", "raid3" }
    local sortFunction = fsCompare:SortFunction(subject)

    assert(sortFunction == nil)
end

function M:test_sort_reverse_group()
    local config = addon.DB.Options.Sorting.World
    config.Enabled = true
    config.PlayerSortMode = nil
    config.GroupSortMode = fsConfig.GroupSortMode.Group
    config.Reverse = true

    local subject = { "raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "raid8", "raid7", "raid6", "raid5", "raid4", "raid3", "raid2", "raid1" })
end

return M
