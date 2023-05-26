local deps = {
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

function M:test_is_player_pet()
    assertEquals(unit:IsPet("pet"), true)
    assertEquals(unit:IsPet("playerpet"), true)
end

function M:test_is_party_pet()
    assertEquals(unit:IsPet("party1pet"), true)
    assertEquals(unit:IsPet("party2pet"), true)
    assertEquals(unit:IsPet("party3pet"), true)
    assertEquals(unit:IsPet("party4pet"), true)
end

function M:test_is_raid_pet()
    assertEquals(unit:IsPet("raid1pet"), true)
    assertEquals(unit:IsPet("raid2pet"), true)
    assertEquals(unit:IsPet("raid3pet"), true)
    assertEquals(unit:IsPet("raid4pet"), true)
    assertEquals(unit:IsPet("raid10pet"), true)
    assertEquals(unit:IsPet("raid19pet"), true)
    assertEquals(unit:IsPet("raid39pet"), true)
    assertEquals(unit:IsPet("raid40pet"), true)
end

function M:test_is_not_pet()
    assertEquals(unit:IsPet(""), false)
    assertEquals(unit:IsPet("none"), false)
    assertEquals(unit:IsPet("player"), false)
    assertEquals(unit:IsPet("party1"), false)
    assertEquals(unit:IsPet("raid1"), false)
    assertEquals(unit:IsPet("raid1"), false)
    assertEquals(unit:IsPet("somethingpet"), false)
    assertEquals(unit:IsPet("petsomething"), false)
end

return M
