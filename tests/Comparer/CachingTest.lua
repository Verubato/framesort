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
    local prefix = "party"
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

function M:test_ordering_cache_invalidation_required()
    local config = addon.DB.Options.Sorting.World
    config.PlayerSortMode = nil
    config.GroupSortMode = fsConfig.GroupSortMode.Role

    addon.WoW.Api.UnitGroupRolesAssigned = function(unit)
        if unit == "party2" then
            return "TANK"
        end
        if unit == "player" then
            return "HEALER"
        end
        return "DAMAGER"
    end
    addon.WoW.Api.UnitClass = function(unit)
        local map = {
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

        return "", "", map[unit]
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

    local subject1 = { "player", "party1", "party2", "party3", "party4" }
    local f1 = fsCompare:SortFunction(subject1)
    table.sort(subject1, f1)
    assertEquals(subject1, { "party2", "player", "party3", "party4", "party1" })

    -- Change ordering
    ordering.Tanks = 5
    ordering.Healers = 4
    ordering.Hunters = 3
    ordering.Casters = 2
    ordering.Melee = 1

    fsCompare:InvalidateCache()

    local subject2 = { "player", "party1", "party2", "party3", "party4" }
    local f2 = fsCompare:SortFunction(subject2)
    table.sort(subject2, f2)

    assertEquals(subject2, { "party1", "party4", "party3", "player", "party2" })
end

return M
