local deps = {
    "Wow\\Unit.lua",
    "Configuration\\SortMode.lua",
    "Collections\\Enumerable.lua",
    "Collections\\Comparer.lua",
}

local addon = nil
---@type Comparer
local fsCompare = nil
---@type Configuration
local fsConfig = nil
local M = {}

function M:setup()
    addon = {
        Collections = {},
        Configuration = {},
        Numerics = {},
        WoW = {
            Api = {},
        },
        Utils = {},
    }

    local helper = require("Helper")
    helper:LoadDependencies(addon, deps)

    local playerToken = "raid2"
    local members = helper:GenerateUnits(8)
    addon.WoW.Api.UnitExists = function(unit)
        return unit == "player" or helper:UnitExists(unit, members)
    end
    addon.WoW.Api.IsInGroup = function()
        return true
    end
    addon.WoW.Api.UnitIsUnit = function(left, right)
        return left == right or (left == playerToken and right == "player")
    end

    fsCompare = addon.Collections.Comparer
    fsConfig = addon.Configuration
end

function M:test_sort_player_top()
    local subject = { "raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8" }
    local sortFunction = function(x, y) return fsCompare:Compare(x, y, fsConfig.PlayerSortMode.Top, fsConfig.GroupSortMode.Group, false, nil) end

    table.sort(subject, sortFunction)

    assertEquals(subject, { "raid2", "raid1", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8" })
end

function M:test_sort_player_bottom()
    local subject = { "raid8", "raid3", "raid4", "raid1", "raid2", "raid7", "raid5", "raid6" }
    local sortFunction = function(x, y) return fsCompare:Compare(x, y, fsConfig.PlayerSortMode.Bottom, fsConfig.GroupSortMode.Group, false, nil) end

    table.sort(subject, sortFunction)

    assertEquals(subject, { "raid1", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8", "raid2" })
end

function M:test_sort_player_middle()
    local presorted = { "raid1", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8" }
    local subject = { "raid2", "raid3", "raid4", "raid8", "raid7", "raid1", "raid5", "raid6" }
    local sortFunction = function(x, y) return fsCompare:Compare(x, y, fsConfig.PlayerSortMode.Middle, fsConfig.GroupSortMode.Group, false, presorted) end

    table.sort(subject, sortFunction)

    assertEquals(subject, { "raid1", "raid3", "raid4", "raid2", "raid5", "raid6", "raid7", "raid8" })
end

return M
