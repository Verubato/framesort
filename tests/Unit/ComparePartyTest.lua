---@type Addon
local addon
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
    addon = addonFactory:Create()
    config = addon.DB.Options.Sorting.World
    fsCompare = addon.Collections.Comparer
    fsConfig = addon.Configuration

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
    local sortFunction = fsCompare:SortFunction()

    table.sort(subject, sortFunction)

    assertEquals(subject, { "player", "party1", "party2", "party3", "party4" })
end

function M:test_sort_player_bottom()
    config.PlayerSortMode = fsConfig.PlayerSortMode.Bottom
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    local subject = { "party2", "party1", "player", "party3", "party4" }
    local sortFunction = fsCompare:SortFunction()

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

function M:test_casters_before_melee()
    config.PlayerSortMode = fsConfig.PlayerSortMode.Top
    config.GroupSortMode = fsConfig.GroupSortMode.Role

    addon.WoW.Api.GetSpecializationInfoByID = function(specIndex)
        if specIndex == 72 then
            return specIndex, "Fury", "", 0, "DAMAGER", "", ""
        elseif specIndex == 105 then
            return specIndex, "Restoration", "", 0, "HEALER", "", ""
        elseif specIndex == 258 then
            return specIndex, "Shadow", "", 0, "DAMAGER", "", ""
        end

        return specIndex, "", "", 0, "NONE", "", ""
    end

    addon.WoW.Api.GetSpecialization = function()
        return 105
    end

    addon.WoW.Api.GetInspectSpecialization = function(unit)
        if unit == "party1" then
            -- fury warrior
            return 72
        elseif unit == "player" then
            -- rdruid
            return 105
        elseif unit == "party2" then
            -- spriest
            return 258
        end

        return 0
    end

    local subject = { "party1", "party2", "player" }
    local sortFunction = fsCompare:SortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "player", "party2", "party1" })
end

return M
