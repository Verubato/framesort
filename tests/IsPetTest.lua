local deps = {
    "Util\\Unit.lua"
}

local addon = {}
for _, fileName in ipairs(deps) do
    local module = loadfile("..\\src\\" .. fileName)
    if module == nil then error("Failed to load " .. fileName) end
    module("UnitTest", addon)
end

local M = {}

function M:test_is_player_pet()
    assertEquals(addon:IsPet("pet"), true)
    assertEquals(addon:IsPet("playerpet"), true)
end

function M:test_is_party_pet()
    assertEquals(addon:IsPet("party1pet"), true)
    assertEquals(addon:IsPet("party2pet"), true)
    assertEquals(addon:IsPet("party3pet"), true)
    assertEquals(addon:IsPet("party4pet"), true)
end

function M:test_is_raid_pet()
    assertEquals(addon:IsPet("raid1pet"), true)
    assertEquals(addon:IsPet("raid2pet"), true)
    assertEquals(addon:IsPet("raid3pet"), true)
    assertEquals(addon:IsPet("raid4pet"), true)
    assertEquals(addon:IsPet("raid10pet"), true)
    assertEquals(addon:IsPet("raid19pet"), true)
    assertEquals(addon:IsPet("raid39pet"), true)
    assertEquals(addon:IsPet("raid40pet"), true)
end

function M:test_is_not_pet()
    assertEquals(addon:IsPet(""), false)
    assertEquals(addon:IsPet("none"), false)
    assertEquals(addon:IsPet("player"), false)
    assertEquals(addon:IsPet("party1"), false)
    assertEquals(addon:IsPet("raid1"), false)
    assertEquals(addon:IsPet("raid1"), false)
    assertEquals(addon:IsPet("somethingpet"), false)
    assertEquals(addon:IsPet("petsomething"), false)
end

return M
