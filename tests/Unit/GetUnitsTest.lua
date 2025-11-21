---@type UnitUtil
local fsUnit
local addon
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

local function UnitExists(unit, members)
    for _, x in pairs(members) do
        if x == unit then
            return true
        end
    end

    return false
end

function M:setup()
    local addonFactory = require("TestHarness\\AddonFactory")
    addon = addonFactory:Create()
    fsUnit = addon.WoW.Unit

    addon.WoW.Api.IsInGroup = function()
        return true
    end
    addon.WoW.Api.UnitIsUnit = function(x, y)
        return x == y
    end
end

function M:test_party_full()
    local count = 5
    local members = GenerateUnits(count)

    addon.WoW.Api.UnitExists = function(x)
        return UnitExists(x, members)
    end

    local units = fsUnit:FriendlyUnits()

    assertEquals(#units, count)
    assertEquals(units[1], "player")

    for i = 1, count - 1 do
        assertEquals(units[i + 1], "party" .. i)
    end
end

function M:test_party3()
    addon.WoW.Api.IsInRaid = function()
        return false
    end

    local count = 3
    local members = GenerateUnits(count)

    addon.WoW.Api.UnitExists = function(x)
        return UnitExists(x, members)
    end

    local units = fsUnit:FriendlyUnits()

    assertEquals(#units, count)
    assertEquals(units[1], "player")

    for i = 1, count - 1 do
        assertEquals(units[i + 1], "party" .. i)
    end
end

function M:test_raid_full()
    addon.WoW.Api.IsInRaid = function()
        return true
    end

    local count = 40
    local members = GenerateUnits(count, true)

    addon.WoW.Api.UnitExists = function(x)
        return UnitExists(x, members)
    end

    local units = fsUnit:FriendlyUnits()

    assertEquals(#units, count)

    for i = 1, count do
        assertEquals(units[i], "raid" .. i)
    end
end

function M:test_raid_empty()
    addon.WoW.Api.IsInRaid = function()
        return true
    end
    addon.WoW.Api.UnitExists = function(_)
        return false
    end

    local units = fsUnit:FriendlyUnits()

    assertEquals(#units, 0)
end

function M:test_raid3()
    addon.WoW.Api.IsInRaid = function()
        return true
    end

    local count = 3
    local members = GenerateUnits(count, true)

    addon.WoW.Api.UnitExists = function(x)
        return UnitExists(x, members)
    end

    local units = fsUnit:FriendlyUnits()

    assertEquals(#units, count)

    for i = 1, count do
        assertEquals(units[i], "raid" .. i)
    end
end

return M
