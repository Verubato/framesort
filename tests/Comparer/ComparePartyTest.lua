---@diagnostic disable: cast-local-type
---@type Addon
local addon
---@type Comparer
local fsCompare
---@type Configuration
local fsConfig
---@type InspectorModule
local fsInspector
local M = {}

local function GenerateUnits(count)
    local members = {
        "player",
    }

    for i = 1, count - 1 do
        members[#members + 1] = "party" .. i
    end

    return members
end

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    addon = addonFactory:Create()
    fsConfig = addon.Configuration
    fsCompare = addon.Modules.Sorting.Comparer
    fsInspector = addon.Modules.Inspector

    fsInspector:Init()

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
    addon.WoW.Api.IsInInstance = function()
        return false, ""
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

    addon.WoW.Api.UnitGroupRolesAssigned = nil
    addon.WoW.Api.UnitClass = nil
    addon.WoW.Api.UnitName = nil
    addon.WoW.Api.UnitGUID = nil
    addon.WoW.Api.UnitExists = nil
    addon.WoW.Api.IsInGroup = nil
    addon.WoW.Api.IsInInstance = nil
    addon.WoW.Api.UnitIsUnit = nil

    addon = nil
    fsCompare = nil
    fsConfig = nil
    fsInspector = nil
end

function M:test_sort_player_top()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = fsConfig.PlayerSortMode.Top
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "party2", "party1", "player", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "player", "party1", "party2", "party3", "party4" })
end

function M:test_sort_player_bottom()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = fsConfig.PlayerSortMode.Bottom
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "party2", "party1", "player", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party1", "party2", "party3", "party4", "player" })
end

function M:test_sort_player_middle_size_2()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = fsConfig.PlayerSortMode.Middle
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "player", "party1" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "player", "party1" })
end

function M:test_sort_player_middle_size_3()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = fsConfig.PlayerSortMode.Middle
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "player", "party1", "party2" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party1", "player", "party2" })
end

function M:test_sort_player_middle_size_4()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = fsConfig.PlayerSortMode.Middle
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "player", "party1", "party2", "party3" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party1", "player", "party2", "party3" })
end

function M:test_sort_player_middle_size_5()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = fsConfig.PlayerSortMode.Middle
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "player", "party1", "party2", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party1", "party2", "player", "party3", "party4" })
end

function M:test_sort_with_nonexistant_units()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = fsConfig.PlayerSortMode.Top
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "party2", "party1", "hello5", "player", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "player", "party1", "party2", "party3", "party4", "hello5" })
end

function M:test_sort_role_tank_healer_dps()
    local config = addon.DB.Options.Sorting.World
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
    local config = addon.DB.Options.Sorting.World
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
    local config = addon.DB.Options.Sorting.World
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
    local config = addon.DB.Options.Sorting.World
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
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = nil
    config.GroupSortMode = fsConfig.GroupSortMode.Role

    local unitToRole = {
        ["player"] = "HEALER",
        ["party1"] = "DAMAGER",
        ["party2"] = "TANK",
        ["party3"] = "HEALER",
        ["party4"] = "DAMAGER",
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

function M:test_sort_player_hidden()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = fsConfig.PlayerSortMode.Hidden
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "party2", "party1", "player", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    -- player shouldbe at the end
    assertEquals(subject, { "party1", "party2", "party3", "party4", "player" })
end

function M:test_sort_disabled_no_reorder()
    local config = addon.DB.Options.Sorting.World
    config.Enabled = false
    config.PlayerSortMode = fsConfig.PlayerSortMode.Top
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "player", "party1", "party2", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    assert(sortFunction == nil)
end

function M:test_sort_group_sortmode_alphabetical()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = nil
    config.GroupSortMode = fsConfig.GroupSortMode.Alphabetical

    local unitToName = {
        ["player"] = "Zed",
        ["party1"] = "Alice",
        ["party2"] = "Bob",
        ["party3"] = "Mona",
        ["party4"] = "Aaron",
    }
    addon.WoW.Api.UnitName = function(unit)
        return unitToName[unit]
    end

    local subject = { "player", "party1", "party2", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party4", "party1", "party2", "party3", "player" })
end

function M:test_sort_role_unknown_role_falls_back_safely()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = nil
    config.GroupSortMode = fsConfig.GroupSortMode.Role

    local unitToRole = {
        ["player"] = "HEALER",
        ["party1"] = "DAMAGER",
        ["party2"] = "TANK",
        ["party3"] = "NONE",
        ["party4"] = nil,
    }

    local unitToClass = {
        -- Druid
        ["player"] = 11,
        -- Death Knight
        ["party1"] = 6,
        -- Warrior
        ["party2"] = 1,
        -- Mage
        ["party3"] = 8,
        -- Hunter
        ["party4"] = 3,
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

    local subject = { "party4", "party3", "party2", "party1", "player" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "party2", "player", "party1", "party4", "party3" })
end

function M:test_sort_role_reverse()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = nil
    config.GroupSortMode = fsConfig.GroupSortMode.Role
    config.Reverse = true

    local unitToRole = {
        ["player"] = "HEALER",
        ["party1"] = "DAMAGER",
        ["party2"] = "TANK",
        ["party3"] = "DAMAGER",
        ["party4"] = "DAMAGER",
    }
    local unitToClass = {
        -- Druid
        ["player"] = 11,
        -- Death Knight
        ["party1"] = 6,
        -- Warrior
        ["party2"] = 1,
        -- Hunter
        ["party3"] = 3,
        -- Mage
        ["party4"] = 8,
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

    local subject = { "player", "party1", "party2", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction(subject)
    table.sort(subject, sortFunction)

    -- In non-reverse you assert { party2, player, party3, party4, party1 }.
    -- Reverse should invert comparisons (except player-mode, which is nil here).
    assertEquals(subject, { "party1", "party4", "party3", "player", "party2" })
end

function M:test_sort_group_reverse()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = nil
    config.GroupSortMode = fsConfig.GroupSortMode.Group
    config.Reverse = true

    local subject = { "party1", "party2", "party3", "party4", "player" }
    local sortFunction = fsCompare:SortFunction(subject)
    table.sort(subject, sortFunction)

    assertEquals(subject, { "player", "party4", "party3", "party2", "party1" })
end

function M:test_pets_sorted_after_players_and_by_owner()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = fsConfig.PlayerSortMode.Top
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    addon.WoW.Api.UnitExists = function(unit)
        return unit == "player" or unit == "party1" or unit == "party2" or unit == "partypet1" or unit == "partypet2"
    end

    local subject = { "partypet2", "party2", "partypet1", "player", "party1" }
    local sortFunction = fsCompare:SortFunction(subject)
    table.sort(subject, sortFunction)

    -- players first in group order, then pets by their owner's order
    assertEquals(subject, { "player", "party1", "party2", "partypet1", "partypet2" })
end

function M:test_player_middle_ignores_pets_for_midpoint()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = fsConfig.PlayerSortMode.Middle
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    addon.WoW.Api.UnitExists = function()
        return true
    end

    local subject = { "player", "party1", "partypet1", "party2", "party3", "party4", "partypet2" }
    local sortFunction = fsCompare:SortFunction(subject)
    table.sort(subject, sortFunction)

    assertEquals(subject, { "party1", "party2", "player", "party3", "party4", "partypet1", "partypet2" })
end

return M
