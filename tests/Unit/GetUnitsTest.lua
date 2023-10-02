local deps = {
    "Collections\\Enumerable.lua",
    "WoW\\Unit.lua",
}

local addon = {}
local helper = {}
local fsUnit = {}
local M = {}

function M:setup()
    addon = {
        Collections = {},
        WoW = {
            Api = {
                MAX_RAID_MEMBERS = 40,
                MEMBERS_PER_RAID_GROUP = 5
            }
        },
    }

    helper = require("Helper")
    helper:LoadDependencies(addon, deps)

    addon.WoW.Api.MAX_RAID_MEMBERS = 40
    addon.WoW.Api.MEMBERS_PER_RAID_GROUP = 5

    addon.WoW.Api.IsInGroup = function()
        return true
    end

    addon.WoW.Api.UnitIsUnit = function(x, y)
        return x == y
    end

    fsUnit = addon.WoW.Unit
end

function M:test_party_full()
    addon.WoW.Api.IsInRaid = function()
        return false
    end

    local count = 5
    local members = helper:GenerateUnits(count)
    addon.WoW.Api.UnitExists = function(x)
        return helper:UnitExists(x, members)
    end

    local units = fsUnit:FriendlyUnits()

    assertEquals(#units, count)
    assertEquals(units[1], "player")

    for i = 1, count - 1 do
        assertEquals(units[i + 1], "party" .. i)
    end
end

function M:test_party_empty()
    addon.WoW.Api.IsInRaid = function()
        return false
    end
    addon.WoW.Api.UnitExists = function(_)
        return false
    end

    local units = fsUnit:FriendlyUnits()

    -- the player token will always exist
    assertEquals(#units, 1)
end

function M:test_party3()
    addon.WoW.Api.IsInRaid = function()
        return false
    end

    local count = 3
    local members = helper:GenerateUnits(count)
    addon.WoW.Api.UnitExists = function(x)
        return helper:UnitExists(x, members)
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
    local members = helper:GenerateUnits(count, true)
    addon.WoW.Api.UnitExists = function(x)
        return helper:UnitExists(x, members)
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
    local members = helper:GenerateUnits(count, true)
    addon.WoW.Api.UnitExists = function(x)
        return helper:UnitExists(x, members)
    end

    local units = fsUnit:FriendlyUnits()

    assertEquals(#units, count)

    for i = 1, count do
        assertEquals(units[i], "raid" .. i)
    end
end

return M
