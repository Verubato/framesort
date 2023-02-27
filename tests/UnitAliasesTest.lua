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

function M:test_get_alias_non_pets()
    assertEquals(addon:GetUnitAliases("player"), { "player" })
    assertEquals(addon:GetUnitAliases("none"), { "none" })
    assertEquals(addon:GetUnitAliases("pet"), { "pet" })
end

function M:test_get_alias_party_pets()
    assertEquals(addon:GetUnitAliases("partypet1"), { "party1pet", "partypet1" })
    assertEquals(addon:GetUnitAliases("party1pet"), { "party1pet", "partypet1" })
end

function M:test_get_alias_raid_pets()
    assertEquals(addon:GetUnitAliases("raidpet1"), { "raid1pet", "raidpet1" })
    assertEquals(addon:GetUnitAliases("raid1pet"), { "raid1pet", "raidpet1" })
end

return M
