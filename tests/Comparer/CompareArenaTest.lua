---@diagnostic disable: cast-local-type
---@type Addon
local addon
---@type Comparer
local fsCompare
---@type Configuration
local fsConfig
local M = {}

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")

    addon = addonFactory:Create()
    fsCompare = addon.Modules.Sorting.Comparer
    fsConfig = addon.Configuration

    addon.WoW.Api.UnitIsUnit = function(left, right)
        return left == right
    end
    addon.WoW.Api.IsInInstance = function()
        return true, "arena"
    end
    addon.WoW.Capabilities.HasEnemySpecSupport = function()
        return true
    end
    addon.WoW.Capabilities.HasSpecializations = function()
        return true
    end
end

function M:teardown()
    local enemy = addon.DB.Options.Sorting.EnemyArena
    enemy.Enabled = false
    enemy.GroupSortMode = nil
    enemy.Reverse = false

    if fsCompare.InvalidateCache then
        fsCompare:InvalidateCache()
    end

    addon.WoW.Api.GetNumArenaOpponentSpecs = nil
    addon.WoW.Api.GetArenaOpponentSpec = nil
    addon.WoW.Api.GetSpecializationInfoByID = nil
    addon.WoW.Api.UnitExists = nil
    addon.WoW.Api.IsInInstance = nil
    addon.WoW.Api.UnitIsUnit = nil

    addon = nil
    fsCompare = nil
    fsConfig = nil
end

function M:test_disabled_returns_nil()
    local config = addon.DB.Options.Sorting.EnemyArena
    config.Enabled = false
    config.GroupSortMode = fsConfig.GroupSortMode.Role

    local subject = { "arena1", "arena2", "arena3" }
    local sortFunction = fsCompare:EnemySortFunction(subject)

    assert(sortFunction == nil)
end

function M:test_group_sortmode_group_orders_by_arena_index()
    local config = addon.DB.Options.Sorting.EnemyArena
    config.Enabled = true
    config.GroupSortMode = fsConfig.GroupSortMode.Group

    addon.WoW.Api.UnitExists = function(unit)
        return unit == "arena1" or unit == "arena2" or unit == "arena3"
    end

    local subject = { "arena3", "arena1", "arena2" }
    local sortFunction = fsCompare:EnemySortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "arena1", "arena2", "arena3" })
end

function M:test_reverse_group()
    local config = addon.DB.Options.Sorting.EnemyArena
    config.Enabled = true
    config.GroupSortMode = fsConfig.GroupSortMode.Group
    config.Reverse = true

    addon.WoW.Api.UnitExists = function(unit)
        return unit == "arena1" or unit == "arena2" or unit == "arena3"
    end

    local subject = { "arena1", "arena2", "arena3" }
    local sortFunction = fsCompare:EnemySortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "arena3", "arena2", "arena1" })
end

function M:test_role()
    local config = addon.DB.Options.Sorting.EnemyArena
    config.Enabled = true
    config.GroupSortMode = fsConfig.GroupSortMode.Role

    addon.WoW.Api.GetNumArenaOpponentSpecs = function()
        return 3
    end
    addon.WoW.Api.GetArenaOpponentSpec = function(id)
        if id == 1 then
            return 72, 0
        end -- melee
        if id == 2 then
            return 105, 0
        end -- healer
        if id == 3 then
            return 258, 0
        end -- caster
        return 0, 0
    end
    addon.WoW.Api.GetSpecializationInfoByID = function(specId)
        if specId == 72 then
            return specId, "Fury", "", 0, "DAMAGER", "", ""
        end
        if specId == 105 then
            return specId, "Restoration", "", 0, "HEALER", "", ""
        end
        if specId == 258 then
            return specId, "Shadow", "", 0, "DAMAGER", "", ""
        end
        return specId, "", "", 0, "NONE", "", ""
    end

    local ordering = addon.DB.Options.Sorting.Ordering
    ordering.Tanks = 1
    ordering.Healers = 2
    ordering.Hunters = 3
    ordering.Casters = 4
    ordering.Melee = 5
    fsCompare:InvalidateCache()

    local subject = { "arena1", "arena2", "arena3" }
    local sortFunction = fsCompare:EnemySortFunction(subject)
    table.sort(subject, sortFunction)

    assertEquals(subject, { "arena2", "arena3", "arena1" })
end

function M:test_role_reverse()
    local config = addon.DB.Options.Sorting.EnemyArena
    config.Enabled = true
    config.GroupSortMode = fsConfig.GroupSortMode.Role
    config.Reverse = true

    addon.WoW.Api.GetNumArenaOpponentSpecs = function()
        return 3
    end
    addon.WoW.Api.GetArenaOpponentSpec = function(id)
        if id == 1 then
            return 72, 0
        end -- melee
        if id == 2 then
            return 105, 0
        end -- healer
        if id == 3 then
            return 258, 0
        end -- caster
        return 0, 0
    end
    addon.WoW.Api.GetSpecializationInfoByID = function(specId)
        if specId == 72 then
            return specId, "Fury", "", 0, "DAMAGER", "", ""
        end
        if specId == 105 then
            return specId, "Restoration", "", 0, "HEALER", "", ""
        end
        if specId == 258 then
            return specId, "Shadow", "", 0, "DAMAGER", "", ""
        end
        return specId, "", "", 0, "NONE", "", ""
    end

    local ordering = addon.DB.Options.Sorting.Ordering
    ordering.Tanks = 1
    ordering.Healers = 2
    ordering.Hunters = 3
    ordering.Casters = 4
    ordering.Melee = 5
    fsCompare:InvalidateCache()

    local subject = { "arena1", "arena2", "arena3" }
    local sortFunction = fsCompare:EnemySortFunction(subject)
    table.sort(subject, sortFunction)

    assertEquals(subject, { "arena1", "arena3", "arena2" })
end

function M:test_unknown_spec_falls_back_safely()
    local config = addon.DB.Options.Sorting.EnemyArena
    config.Enabled = true
    config.GroupSortMode = fsConfig.GroupSortMode.Role
    config.Reverse = false

    addon.WoW.Api.GetNumArenaOpponentSpecs = function()
        return 3
    end
    addon.WoW.Api.GetArenaOpponentSpec = function(id)
        if id == 1 then
            -- unknown
            return 0, 0
        elseif id == 2 then
            -- rdruid
            return 105, 0
        elseif id == 3 then
            -- spriest
            return 258, 0
        end
        return 0, 0
    end

    addon.WoW.Api.GetSpecializationInfoByID = function(specId)
        if specId == 105 then
            return specId, "Restoration", "", 0, "HEALER", "", ""
        elseif specId == 258 then
            return specId, "Shadow", "", 0, "DAMAGER", "", ""
        end

        return specId, "", "", 0, "NONE", "", ""
    end

    local ordering = addon.DB.Options.Sorting.Ordering
    ordering.Tanks = 1
    ordering.Healers = 2
    ordering.Hunters = 3
    ordering.Casters = 4
    ordering.Melee = 5

    fsCompare:InvalidateCache()

    local subject = { "arena1", "arena2", "arena3" }
    local sortFunction = fsCompare:EnemySortFunction(subject)
    table.sort(subject, sortFunction)

    -- Healer should come first, then caster DPS, then unknown.
    -- Unknown has no role/class/spec so it falls back to token/group ordering at the end.
    assertEquals(subject, { "arena2", "arena3", "arena1" })
end

function M:test_pets_after_players_and_by_owner()
    local config = addon.DB.Options.Sorting.EnemyArena
    config.Enabled = true
    config.GroupSortMode = fsConfig.GroupSortMode.Group
    config.Reverse = false

    local subject = { "arenapet1", "arena1", "arenapet3", "arena3", "arenapet2", "arena2" }
    local sortFunction = fsCompare:EnemySortFunction(subject)
    table.sort(subject, sortFunction)

    assertEquals(subject, { "arena1", "arena2", "arena3", "arenapet1", "arenapet2", "arenapet3" })
end

function M:test_casters_before_melee()
    local config = addon.DB.Options.Sorting.EnemyArena
    config.Enabled = true
    config.GroupSortMode = fsConfig.GroupSortMode.Role

    addon.WoW.Api.GetNumArenaOpponentSpecs = function()
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

        assert(false)
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

        assert(false)
        return specIndex, "", "", 0, "NONE", "", ""
    end

    local ordering = addon.DB.Options.Sorting.Ordering
    ordering.Tanks = 1
    ordering.Healers = 2
    ordering.Hunters = 3
    ordering.Casters = 4
    ordering.Melee = 5

    local subject = { "arena1", "arena2", "arena3" }
    local sortFunction = fsCompare:EnemySortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "arena2", "arena3", "arena1" })
end

function M:test_hunters_between_casters_and_melee()
    local config = addon.DB.Options.Sorting.EnemyArena
    config.Enabled = true
    config.GroupSortMode = fsConfig.GroupSortMode.Role

    addon.WoW.Api.GetNumArenaOpponentSpecs = function()
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

        assert(false)
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

        assert(false)
        return specIndex, "", "", 0, "NONE", "", ""
    end

    local ordering = addon.DB.Options.Sorting.Ordering
    ordering.Tanks = 1
    ordering.Healers = 2
    ordering.Casters = 3
    ordering.Hunters = 4
    ordering.Melee = 5

    local subject = { "arena1", "arena2", "arena3" }
    local sortFunction = fsCompare:EnemySortFunction(subject)

    table.sort(subject, sortFunction)

    assertEquals(subject, { "arena3", "arena1", "arena2" })
end

return M
