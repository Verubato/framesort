local deps = {
    "Util\\Unit.lua",
}

local addon = nil
local helper = nil
local M = {}

function M:setUp()
    addon = { WoW = {} }

    helper = require("Helper")
    helper:LoadDependencies(addon, deps)

    addon.WoW.MAX_RAID_MEMBERS = 40
    addon.WoW.MEMBERS_PER_RAID_GROUP = 5

    addon.WoW.IsInGroup = function()
        return true
    end
end

function M:test_party_full()
    addon.WoW.IsInRaid = function()
        return false
    end

    local count = 5
    local members = helper:GenerateUnits(count)
    addon.WoW.UnitExists = function(x)
        return helper:UnitExists(x, members)
    end

    local units = addon.Unit:FriendlyUnits()

    assertEquals(#units, count)
    assertEquals(units[1], "player")

    for i = 1, count - 1 do
        assertEquals(units[i + 1], "party" .. i)
    end
end

function M:test_party_empty()
    addon.WoW.IsInRaid = function()
        return false
    end
    addon.WoW.UnitExists = function(_)
        return false
    end

    local units = addon.Unit:FriendlyUnits()

    -- the player token will always exist
    assertEquals(#units, 1)
end

function M:test_party3()
    addon.WoW.IsInRaid = function()
        return false
    end

    local count = 3
    local members = helper:GenerateUnits(count)
    addon.WoW.UnitExists = function(x)
        return helper:UnitExists(x, members)
    end

    local units = addon.Unit:FriendlyUnits()

    assertEquals(#units, count)
    assertEquals(units[1], "player")

    for i = 1, count - 1 do
        assertEquals(units[i + 1], "party" .. i)
    end
end

function M:test_raid_full()
    addon.WoW.IsInRaid = function()
        return true
    end

    local count = 40
    local members = helper:GenerateUnits(count, true)
    addon.WoW.UnitExists = function(x)
        return helper:UnitExists(x, members)
    end

    local units = addon.Unit:FriendlyUnits()

    assertEquals(#units, count)

    for i = 1, count do
        assertEquals(units[i], "raid" .. i)
    end
end

function M:test_raid_empty()
    addon.WoW.IsInRaid = function()
        return true
    end
    addon.WoW.UnitExists = function(_)
        return false
    end

    local units = addon.Unit:FriendlyUnits()

    assertEquals(#units, 0)
end

function M:test_raid3()
    addon.WoW.IsInRaid = function()
        return true
    end

    local count = 3
    local members = helper:GenerateUnits(count, true)
    addon.WoW.UnitExists = function(x)
        return helper:UnitExists(x, members)
    end

    local units = addon.Unit:FriendlyUnits()

    assertEquals(#units, count)

    for i = 1, count do
        assertEquals(units[i], "raid" .. i)
    end
end

return M
