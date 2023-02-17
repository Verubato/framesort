local deps = {
    "Unit.lua"
}

local addon = {}
for _, fileName in ipairs(deps) do
    local module = loadfile("..\\src\\" .. fileName)
    if module == nil then error("Failed to load " .. fileName) end
    module("UnitTest", addon)
end

local mock = require("Mock")
local M = {}

function M:setUp()
    MAX_RAID_MEMBERS = 40
    MEMBERS_PER_RAID_GROUP = 5
end

function M:test_party_full()
    IsInRaid = function() return false end

    local count = 5
    local members = mock:GenerateUnits(count)
    UnitExists = function(unit) return mock:UnitExists(unit, members) end

    local units = addon:GetUnits()

    assertEquals(#units, count)
    assertEquals(units[1], "player")

    for i = 1, count - 1 do
        assertEquals(units[i + 1], "party" .. i)
    end
end

function M:test_party_empty()
    IsInRaid = function() return false end
    UnitExists = function(_) return false end

    local units = addon:GetUnits()

    -- the player token will always exist
    assertEquals(#units, 1)
end

function M:test_party3()
    IsInRaid = function() return false end

    local count = 3
    local members = mock:GenerateUnits(count)
    UnitExists = function(unit) return mock:UnitExists(unit, members) end

    local units = addon:GetUnits()

    assertEquals(#units, count)
    assertEquals(units[1], "player")

    for i = 1, count - 1 do
        assertEquals(units[i + 1], "party" .. i)
    end
end

function M:test_raid_full()
    IsInRaid = function() return true end

    local count = 40
    local members = mock:GenerateUnits(count, true)
    UnitExists = function(unit) return mock:UnitExists(unit, members) end

    local units = addon:GetUnits()

    assertEquals(#units, count)

    for i = 1, count do
        assertEquals(units[i], "raid" .. i)
    end
end

function M:test_raid_empty()
    IsInRaid = function() return true end
    UnitExists = function(_) return false end

    local units = addon:GetUnits()

    assertEquals(#units, 0)
end

function M:test_raid3()
    IsInRaid = function() return true end

    local count = 3
    local members = mock:GenerateUnits(count, true)
    print("TEST" .. tostring(#members))
    UnitExists = function(unit) return mock:UnitExists(unit, members) end

    local units = addon:GetUnits()

    assertEquals(#units, count)

    for i = 1, count do
        assertEquals(units[i], "raid" .. i)
    end
end

return M
