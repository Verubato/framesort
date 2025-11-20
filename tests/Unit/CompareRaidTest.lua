local config
---@type Comparer
local fsCompare
---@type Configuration
local fsConfig
local M = {}

local function GenerateUnits(count, isRaid)
    isRaid = isRaid or count > 5

    local prefix = isRaid and "raid" or "party"
    local toGenerate = isRaid and count or count - 1
    local members = {}

    -- raids don't have the "player" token
    if not isRaid then
        table.insert(members, "player")
    end

    for i = 1, toGenerate do
        table.insert(members, prefix .. i)
    end

    return members
end

function M:setup()
    local addonFactory = require("Mock\\AddonFactory")
    local addon = addonFactory:Create()

    config = addon.DB.Options.Sorting.World
    fsCompare = addon.Modules.Sorting.Comparer
    fsConfig = addon.Configuration

    addon.DB.Options.Sorting.World.Enabled = true

    local playerToken = "raid2"
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

function M:test_sort_player_top()
    config.PlayerSortMode = fsConfig.PlayerSortMode.Top
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "raid2", "raid1", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8" })
end

function M:test_sort_player_bottom()
    config.PlayerSortMode = fsConfig.PlayerSortMode.Bottom
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "raid8", "raid3", "raid4", "raid1", "raid2", "raid7", "raid5", "raid6" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "raid1", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8", "raid2" })
end

function M:test_sort_player_middle()
    config.PlayerSortMode = fsConfig.PlayerSortMode.Middle
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "raid2", "raid3", "raid4", "raid7", "raid1", "raid5", "raid6" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "raid1", "raid3", "raid4", "raid2", "raid5", "raid6", "raid7" })
end

return M
