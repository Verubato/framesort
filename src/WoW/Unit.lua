---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local wowEx = addon.WoW.WowEx
local capabilities = addon.WoW.Capabilities
local fsEnumerable = addon.Collections.Enumerable
local fsLog = addon.Logging.Log
---@class UnitUtil
local M = {}
addon.WoW.Unit = M

local allPartyUnitsIds = {
    "player",
    "pet",
}
local allRaidUnitsIds = {}
local allArenaUnitsIds = {}

for i = 1, wow.MAX_PARTY_MEMBERS do
    allPartyUnitsIds[#allPartyUnitsIds + 1] = "party" .. i
end

for i = 1, wow.MAX_PARTY_MEMBERS do
    allPartyUnitsIds[#allPartyUnitsIds + 1] = "partypet" .. i
end

for i = 1, wow.MAX_RAID_MEMBERS do
    allRaidUnitsIds[#allRaidUnitsIds + 1] = "raid" .. i
end

for i = 1, wow.MAX_RAID_MEMBERS do
    allRaidUnitsIds[#allRaidUnitsIds + 1] = "raidpet" .. i
end

-- brawl can have 15 people in arena
local maxArena = 15
for i = 1, maxArena do
    allArenaUnitsIds[#allArenaUnitsIds + 1] = "arena" .. i
end

for i = 1, maxArena do
    allArenaUnitsIds[#allArenaUnitsIds + 1] = "arenapet" .. i
end

---Normalises unit tokens, such that party1pet becomes partypet1.
---@param unit string
---@return string|nil
function M:NormaliseUnit(unit)
    if type(unit) ~= "string" or unit == "" then
        return nil
    end

    unit = string.lower(unit)

    -- already canonical (party1, partypet1, raidpet13, arena3, arenapet2, etc)
    if unit:match("^partypet%d+$") or unit:match("^raidpet%d+$") or unit:match("^arenapet%d+$") then
        return unit
    end

    local n

    n = unit:match("^party(%d+)pet$")

    if n then
        return "partypet" .. n
    end

    n = unit:match("^raid(%d+)pet$")

    if n then
        return "raidpet" .. n
    end

    n = unit:match("^arena(%d+)pet$")

    if n then
        return "arenapet" .. n
    end

    return unit
end

function M:EnemyUnitExists(unit)
    if not unit then
        fsLog:Error("Unit:EnemyUnitExists() - unit must not be nil.")
        return false
    end

    -- after the gates open UnitExists will start working
    local exists = wow.UnitExists(unit)

    if not wow.issecretvalue(exists) and exists then
        return true
    end

    -- get the number from the token, e.g. "2" from "arena2"
    local idStr = string.match(unit, "%d+")

    if not idStr then
        return false
    end

    local arenaCount = wowEx.ArenaOpponentsCount()

    if arenaCount and arenaCount > 0 then
        local id = tonumber(idStr)
        return id and id <= arenaCount or false
    end

    if not capabilities.HasC_PvP() or not wow.C_PvP or not wow.C_PvP.GetScoreInfoByPlayerGuid then
        return false
    end

    local guid = wow.UnitGUID and wow.UnitGUID(unit)

    if not guid or wow.issecretvalue(guid) then
        return false
    end

    local info = wow.C_PvP.GetScoreInfoByPlayerGuid(guid)
    return info ~= nil and info.name ~= nil
end

---Returns a table of group member unit tokens where the unit exists.
---@return string[]
function M:FriendlyUnits()
    if not wow.IsInGroup() then
        return {}
    end

    local isRaid = wow.IsInRaid()
    local units = isRaid and allRaidUnitsIds or allPartyUnitsIds

    return fsEnumerable
        :From(units)
        :Where(function(unit)
            local exists = wow.UnitExists(unit)
            return not wow.issecretvalue(exists) and exists
        end)
        :ToTable()
end

---Returns a table of arena unit tokens where the unit exists.
---@return string[]
function M:ArenaUnits()
    if not wowEx.IsInstanceArenaOrBrawl() then
        return {}
    end

    return fsEnumerable
        :From(allArenaUnitsIds)
        :Where(function(unit)
            return M:EnemyUnitExists(unit)
        end)
        :ToTable()
end

---Returns true if the unit token is a pet.
---@param unit string
function M:IsPet(unit)
    if not unit then
        return false
    end

    return unit == "pet"
        or unit == "playerpet"
        or unit:match("^party%d+pet$") ~= nil
        or unit:match("^partypet%d+$") ~= nil
        or unit:match("^raid%d+pet$") ~= nil
        or unit:match("^raidpet%d+$") ~= nil
        or unit:match("^arena%d+pet$") ~= nil
        or unit:match("^arenapet%d+$") ~= nil
end

---Returns the pet unit for the specified unit.
---@param unit string
---@param isEnemy boolean? pass true if unit is an enemy, used to avoid comparing secret values.
---@return string
function M:PetFor(unit, isEnemy)
    if not unit or unit == "" or unit == "none" then
        return "none"
    end

    if unit == "playerpet" then
        return "pet"
    end

    if M:IsPet(unit) then
        return unit
    end

    -- isEnemy used here as UnitIsUnit returns a secret value for enemy units (e.g. arena123)
    local isPlayer = not isEnemy and M:IsPlayer(unit)

    if unit == "player" or isPlayer then
        return "pet"
    end

    -- party1 -> partypet1
    local n = unit:match("^party(%d+)$")
    if n then
        return "partypet" .. n
    end

    -- raid1 -> raidpet1
    n = unit:match("^raid(%d+)$")
    if n then
        return "raidpet" .. n
    end

    -- arena1 -> arenapet1
    n = unit:match("^arena(%d+)$")
    if n then
        return "arenapet" .. n
    end

    return "none"
end

---Returns the parent token of a given pet unit, e.g. arenapet3 becomes arena3
---@param petUnit any
---@return string
function M:PetOwner(petUnit)
    if not petUnit or petUnit == "" or petUnit == "none" then
        return "none"
    end

    if petUnit == "pet" then
        return "player"
    end

    local pos = string.find(petUnit, "pet", 1, true)
    if not pos then
        return petUnit
    end

    return petUnit:sub(1, pos - 1) .. petUnit:sub(pos + 3)
end

---A safe check wrapper that returns true if the unit is "player"
---@param unit string
function M:IsPlayer(unit)
    if not unit then
        fsLog:Error("Unit:IsPlayer() - unit must not be nil.")
        return false
    end

    local isPlayerMaybeSecret = wow.UnitIsUnit(unit, "player")

    if wow.issecretvalue(isPlayerMaybeSecret) then
        return false
    end

    return isPlayerMaybeSecret
end

---Returns true if the unit is friendly to the current player.
---@param unit string
function M:IsFriendlyUnit(unit)
    if not unit then
        fsLog:Error("Unit:IsFriendlyUnit() - unit must not be nil.")
        return false
    end

    local isFriendOrSecret = wow.UnitIsFriend("player", unit)
    return not wow.issecretvalue(isFriendOrSecret) and isFriendOrSecret
end

---Returns true if the unit is an enemy of the current player.
---@param unit string
function M:IsEnemyUnit(unit)
    if not unit then
        fsLog:Error("Unit:IsEnemyUnit() - unit must not be nil.")
        return false
    end

    local isEnemyOrSecret = wow.UnitIsEnemy("player", unit)
    return not wow.issecretvalue(isEnemyOrSecret) and isEnemyOrSecret
end
