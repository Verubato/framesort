---@type Addon
local addon
local config
---@type Comparer
local fsCompare
---@type Configuration
local fsConfig
local M = {}

function M:setup()
    local addonFactory = require("Mock\\AddonFactory")

    addon = addonFactory:Create()
    config = addon.DB.Options.Sorting.EnemyArena
    fsCompare = addon.Modules.Sorting.Comparer
    fsConfig = addon.Configuration

    addon.WoW.Api.UnitIsUnit = function(left, right)
        return left == right
    end
    addon.WoW.Api.IsInInstance = function()
        return true, "arena"
    end
end

function M:test_casters_before_melee()
    config.Enabled = true
    config.GroupSortMode = fsConfig.GroupSortMode.Role

    addon.WoW.Api.GetNumGroupMembers = function()
        return 3
    end
    addon.WoW.Api.GetArenaOpponentSpec = function(id)
        if id == 1 then
            -- fury warrior
            return 72, 0
        elseif id == 2 then
            -- rdruid
            return 105, 0
        elseif id == 3 then
            -- spriest
            return 258, 0
        end

        return 0, 0
    end
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

    local subject = { "arena1", "arena2", "arena3" }
    local sortFunction = fsCompare:EnemySortFunction()

    table.sort(subject, sortFunction)

    assertEquals(subject, { "arena2", "arena3", "arena1" })
end

function M:test_hunters_between_casters_and_melee()
    config.Enabled = true
    config.GroupSortMode = fsConfig.GroupSortMode.Role

    addon.WoW.Api.GetNumGroupMembers = function()
        return 3
    end
    addon.WoW.Api.GetArenaOpponentSpec = function(id)
        if id == 1 then
            -- mm hunter
            return 254, 0
        elseif id == 2 then
            -- ret paladin
            return 70, 0
        elseif id == 3 then
            -- spriest
            return 258, 0
        end

        return 0, 0
    end
    addon.WoW.Api.GetSpecializationInfoByID = function(specIndex)
        if specIndex == 254 then
            return specIndex, "Marksmanship", "", 0, "DAMAGER", "", ""
        elseif specIndex == 70 then
            return specIndex, "Retribution", "", 0, "DAMAGER", "", ""
        elseif specIndex == 258 then
            return specIndex, "Shadow", "", 0, "DAMAGER", "", ""
        end

        return specIndex, "", "", 0, "NONE", "", ""
    end

    local subject = { "arena1", "arena2", "arena3" }
    local sortFunction = fsCompare:EnemySortFunction()

    table.sort(subject, sortFunction)

    assertEquals(subject, { "arena3", "arena1", "arena2" })
end

return M
