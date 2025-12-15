---@type Addon
local addon
local config
---@type Comparer
local fsCompare
---@type Configuration
local fsConfig
---@type InspectorModule
local fsInspector
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
    local addonFactory = require("TestHarness\\AddonFactory")
    addon = addonFactory:Create()
    fsConfig = addon.Configuration
    config = addon.DB.Options.Sorting.World
    fsCompare = addon.Modules.Sorting.Comparer
    fsInspector = addon.Modules.Inspector

    fsInspector:Init()

    addon.DB.Options.Sorting.World.Enabled = true

    local members = GenerateUnits(5)

    addon.WoW.Api.UnitExists = function(unit)
        for _, x in pairs(members) do
            if x == unit then
                return true
            end
        end

        return false
    end
    addon.WoW.Api.IsInGroup = function()
        return true
    end
end

function M:test_sort_player_top()
    config.PlayerSortMode = fsConfig.PlayerSortMode.Top
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "party2", "party1", "player", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "player", "party1", "party2", "party3", "party4" })
end

function M:test_sort_player_bottom()
    config.PlayerSortMode = fsConfig.PlayerSortMode.Bottom
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "party2", "party1", "player", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party1", "party2", "party3", "party4", "player" })
end

function M:test_sort_player_middle_size_2()
    config.PlayerSortMode = fsConfig.PlayerSortMode.Middle
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "player", "party1" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "player", "party1" })
end

function M:test_sort_player_middle_size_3()
    config.PlayerSortMode = fsConfig.PlayerSortMode.Middle
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "player", "party1", "party2" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party1", "player", "party2" })
end

function M:test_sort_player_middle_size_4()
    config.PlayerSortMode = fsConfig.PlayerSortMode.Middle
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "player", "party1", "party2", "party3" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party1", "player", "party2", "party3" })
end

function M:test_sort_player_middle_size_5()
    config.PlayerSortMode = fsConfig.PlayerSortMode.Middle
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "player", "party1", "party2", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party1", "party2", "player", "party3", "party4" })
end

function M:test_sort_with_nonexistant_units()
    config.PlayerSortMode = fsConfig.PlayerSortMode.Top
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "party2", "party1", "hello5", "player", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "player", "party1", "party2", "party3", "party4", "hello5" })
end

function M:test_sort_role_tank_healer_dps()
    config.PlayerSortMode = nil
    config.GroupSortMode = fsConfig.GroupSortMode.Role

    local unitToRole = {
        ["player"] = "HEALER",
        ["party1"] = "DAMAGER",
        ["party2"] = "TANK",
        ["party3"] = "DAMAGER",
        ["party4"] = "DAMAGER",
    }

    local unitToClass = {
        -- rdruid
        ["player"] = 11,
        -- unholy  dk,
        ["party1"] = 6,
        -- prot warrior
        ["party2"] = 1,
        -- bm hunter
        ["party3"] = 3,
        -- arcane mage
        ["party4"] = 8,
    }

    addon.WoW.Api.UnitGroupRolesAssigned = function(unit)
        return unitToRole[unit]
    end
    addon.WoW.Api.UnitClass = function(unit)
        return "", "", unitToClass[unit]
    end
    addon.WoW.Api.UnitGUID = function(unit)
        return unit .. unit
    end

    local ordering = addon.DB.Options.Sorting.Ordering
    ordering.Tanks = 1
    ordering.Healers = 2
    ordering.Hunters = 3
    ordering.Casters = 4
    ordering.Melee = 5

    local subject = { "player", "party1", "party2", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party2", "player", "party3", "party4", "party1" })
end

function M:test_sort_role_melee_caster_hunter_healer_tank()
    config.PlayerSortMode = nil
    config.GroupSortMode = fsConfig.GroupSortMode.Role

    local unitToRole = {
        ["player"] = "HEALER",
        ["party1"] = "DAMAGER",
        ["party2"] = "TANK",
        ["party3"] = "DAMAGER",
        ["party4"] = "DAMAGER",
    }

    local unitToClass = {
        -- rdruid
        ["player"] = 11,
        -- unholy  dk,
        ["party1"] = 6,
        -- prot warrior
        ["party2"] = 1,
        -- bm hunter
        ["party3"] = 3,
        -- arcane mage
        ["party4"] = 8,
    }

    addon.WoW.Api.UnitGroupRolesAssigned = function(unit)
        return unitToRole[unit]
    end
    addon.WoW.Api.UnitClass = function(unit)
        return "", "", unitToClass[unit]
    end
    addon.WoW.Api.UnitGUID = function(unit)
        return unit .. unit
    end

    local ordering = addon.DB.Options.Sorting.Ordering
    ordering.Tanks = 5
    ordering.Healers = 4
    ordering.Hunters = 3
    ordering.Casters = 2
    ordering.Melee = 1

    local subject = { "player", "party1", "party2", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party1", "party4", "party3", "player", "party2" })
end

function M:test_sort_druids_of_all_roles()
    config.PlayerSortMode = nil
    config.GroupSortMode = fsConfig.GroupSortMode.Role

    local unitToRole = {
        ["player"] = "HEALER",
        ["party1"] = "DAMAGER",
        ["party2"] = "TANK",
        ["party3"] = "DAMAGER",
        ["party4"] = "DAMAGER",
    }

    addon.WoW.Api.UnitGroupRolesAssigned = function(unit)
        return unitToRole[unit]
    end
    addon.WoW.Api.UnitClass = function(unit)
        -- all druids
        return "", "", 11
    end
    addon.WoW.Api.UnitGUID = function(unit)
        return unit .. unit
    end

    local ordering = addon.DB.Options.Sorting.Ordering
    ordering.Tanks = 1
    ordering.Healers = 2
    ordering.Hunters = 3
    ordering.Casters = 4
    ordering.Melee = 5

    -- resto
    fsInspector:Add("player", 105)

    -- boomkin
    fsInspector:Add("party1", 102)

    -- guardian
    fsInspector:Add("party2", 104)

    -- feral
    fsInspector:Add("party3", 103)

    -- feral
    fsInspector:Add("party4", 103)

    local subject = { "player", "party1", "party2", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party2", "player", "party1", "party3", "party4" })
end

function M:test_sort_shamans_of_all_roles()
    config.PlayerSortMode = nil
    config.GroupSortMode = fsConfig.GroupSortMode.Role

    local unitToRole = {
        ["player"] = "HEALER",
        ["party1"] = "DAMAGER",
        ["party2"] = "HEALER",
        ["party3"] = "DAMAGER",
        ["party4"] = "DAMAGER",
    }

    addon.WoW.Api.UnitGroupRolesAssigned = function(unit)
        return unitToRole[unit]
    end
    addon.WoW.Api.UnitClass = function(unit)
        -- all shamans
        return "", "", 7
    end
    addon.WoW.Api.UnitGUID = function(unit)
        return unit .. unit
    end

    local ordering = addon.DB.Options.Sorting.Ordering
    ordering.Tanks = 1
    ordering.Healers = 2
    ordering.Hunters = 3
    ordering.Casters = 4
    ordering.Melee = 5

    -- resto
    fsInspector:Add("player", 264)

    -- ele
    fsInspector:Add("party1", 262)

    -- resto
    fsInspector:Add("party2", 264)

    -- enhance
    fsInspector:Add("party3", 263)

    -- ele
    fsInspector:Add("party4", 262)

    local subject = { "player", "party1", "party2", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party2", "player", "party1", "party4", "party3" })
end

function M:test_sort_druids_and_shamans()
    config.PlayerSortMode = nil
    config.GroupSortMode = fsConfig.GroupSortMode.Role

    local unitToRole = {
        ["player"] = "HEALER",
        ["party1"] = "DAMAGER",
        ["party2"] = "TANK",
        ["party3"] = "HEALER",
        ["party4"] = "DAMANGER",
    }

    local unitToClass = {
        -- druids
        ["player"] = 11,
        ["party1"] = 11,
        ["party2"] = 11,
        -- shamans
        ["party3"] = 7,
        ["party4"] = 7,
    }

    addon.WoW.Api.UnitGroupRolesAssigned = function(unit)
        return unitToRole[unit]
    end
    addon.WoW.Api.UnitClass = function(unit)
        -- all shamans
        return "", "", unitToClass[unit]
    end
    addon.WoW.Api.UnitGUID = function(unit)
        return unit .. unit
    end

    local ordering = addon.DB.Options.Sorting.Ordering
    ordering.Tanks = 1
    ordering.Healers = 2
    ordering.Hunters = 3
    ordering.Casters = 4
    ordering.Melee = 5

    -- rdruid
    fsInspector:Add("player", 105)

    -- feral
    fsInspector:Add("party1", 103)

    -- guardian
    fsInspector:Add("party2", 104)

    -- rsham
    fsInspector:Add("party3", 264)

    -- enhance
    fsInspector:Add("party4", 263)

    local subject = { "player", "party1", "party2", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party2", "player", "party3", "party1", "party4" })
end

return M
