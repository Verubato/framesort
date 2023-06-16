local deps = {
    "Util\\Enumerable.lua",
    "Util\\Unit.lua"
}

local addon = {}
for _, fileName in ipairs(deps) do
    local module = loadfile("..\\src\\" .. fileName)
    if module == nil then error("Failed to load " .. fileName) end
    module("UnitTest", addon)
end

local unit = addon.Unit
local M = {}

function M:test_is_member_player()
    assertEquals(unit:IsMember("player"), true)
end

function M:test_is_party_member()
    assertEquals(unit:IsMember("party1"), true)
    assertEquals(unit:IsMember("party2"), true)
    assertEquals(unit:IsMember("party3"), true)
    assertEquals(unit:IsMember("party4"), true)
end

function M:test_is_raid_member()
    assertEquals(unit:IsMember("raid1"), true)
    assertEquals(unit:IsMember("raid2"), true)
    assertEquals(unit:IsMember("raid3"), true)
    assertEquals(unit:IsMember("raid4"), true)
    assertEquals(unit:IsMember("raid10"), true)
    assertEquals(unit:IsMember("raid19"), true)
    assertEquals(unit:IsMember("raid39"), true)
    assertEquals(unit:IsMember("raid40"), true)
end

function M:test_is_not_member()
    assertEquals(unit:IsMember(""), false)
    assertEquals(unit:IsMember("none"), false)
    assertEquals(unit:IsMember("pet"), false)
    assertEquals(unit:IsMember("playerpet"), false)
    assertEquals(unit:IsMember("party1pet"), false)
end

return M
