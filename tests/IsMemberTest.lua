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

function M:test_is_member_player()
    assertEquals(addon:IsMember("player"), true)
end

function M:test_is_party_member()
    assertEquals(addon:IsMember("party1"), true)
    assertEquals(addon:IsMember("party2"), true)
    assertEquals(addon:IsMember("party3"), true)
    assertEquals(addon:IsMember("party4"), true)
end

function M:test_is_raid_member()
    assertEquals(addon:IsMember("raid1"), true)
    assertEquals(addon:IsMember("raid2"), true)
    assertEquals(addon:IsMember("raid3"), true)
    assertEquals(addon:IsMember("raid4"), true)
    assertEquals(addon:IsMember("raid10"), true)
    assertEquals(addon:IsMember("raid19"), true)
    assertEquals(addon:IsMember("raid39"), true)
    assertEquals(addon:IsMember("raid40"), true)
end

function M:test_is_not_member()
    assertEquals(addon:IsMember(""), false)
    assertEquals(addon:IsMember("none"), false)
    assertEquals(addon:IsMember("pet"), false)
    assertEquals(addon:IsMember("playerpet"), false)
    assertEquals(addon:IsMember("party1pet"), false)
end

return M
