---@type UnitUtil
local fsUnit
local addon
local M = {}

local function GenerateUnits(type, count)
    local members = {}

    if type == "party" then
        table.insert(members, "player")
    end

    for i = 1, count - #members do
        table.insert(members, type .. i)
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
    local members = GenerateUnits("party", count)

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
    local members = GenerateUnits("party", count)

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
    local members = GenerateUnits("raid", count)

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
    local members = GenerateUnits("raid", count)

    addon.WoW.Api.UnitExists = function(x)
        return UnitExists(x, members)
    end

    local units = fsUnit:FriendlyUnits()

    assertEquals(#units, count)

    for i = 1, count do
        assertEquals(units[i], "raid" .. i)
    end
end

function M:test_arena_3v3()
    local count = 3
    local members = GenerateUnits("arena", count)

    assertEquals(#members, count)

    addon.WoW.Api.UnitExists = function(x)
        return UnitExists(x, members)
    end
    addon.WoW.Api.IsInInstance = function()
        return true, "arena"
    end

    addon.WoW.Api.GetNumArenaOpponentSpecs = function()
        return count
    end
    addon.WoW.Api.GetNumGroupMembers = function()
        return count
    end

    local units = fsUnit:EnemyUnits()

    -- don't assert #units == count here because it will also include pets
    for i = 1, count do
        assertEquals(units[i], "arena" .. i)
    end
end

function M:test_is_pet()
    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(fsUnit:IsPet(nil), false)
    assertEquals(fsUnit:IsPet(""), false)
    assertEquals(fsUnit:IsPet("player"), false)
    assertEquals(fsUnit:IsPet("party1"), false)
    assertEquals(fsUnit:IsPet("arena1"), false)
    assertEquals(fsUnit:IsPet("nameplate1"), false)

    assertEquals(fsUnit:IsPet("pet"), true)
    assertEquals(fsUnit:IsPet("playerpet"), true)
    assertEquals(fsUnit:IsPet("party1pet"), true)
    assertEquals(fsUnit:IsPet("arena1pet"), true)
    assertEquals(fsUnit:IsPet("raid1pet"), true)
    assertEquals(fsUnit:IsPet("nameplate1pet"), true)
end

function M:test_pet_for()
    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(fsUnit:PetFor(nil), "none")
    assertEquals(fsUnit:PetFor(""), "none")
    assertEquals(fsUnit:PetFor("player"), "pet")
    assertEquals(fsUnit:PetFor("party1"), "partypet1")
    assertEquals(fsUnit:PetFor("raid1"), "raidpet1")
    assertEquals(fsUnit:PetFor("nameplate1"), "nameplatepet1")

    assertEquals(fsUnit:PetFor("arena1", true), "arenapet1")
    assertEquals(fsUnit:PetFor("nameplate1", true), "nameplatepet1")
end

function M:test_owner_for()
    ---@diagnostic disable-next-line: param-type-mismatch
    assertEquals(fsUnit:PetOwner(nil), "none")
    assertEquals(fsUnit:PetOwner(""), "none")
    assertEquals(fsUnit:PetOwner("pet"), "player")
    assertEquals(fsUnit:PetOwner("partypet1"), "party1")
    assertEquals(fsUnit:PetOwner("raidpet1"), "raid1")
    assertEquals(fsUnit:PetOwner("nameplatepet1"), "nameplate1")
end

function M:test_is_player_when_secret()
    addon.WoW.Api.issecretvalue = function(value)
        return true
    end

    local unit = "player"
    local isPlayer = fsUnit:IsPlayer(unit)

    -- because issecretvalue returned true, IsPlayer() should have bailed early and returned false
    assertEquals(isPlayer, false)
end

return M
