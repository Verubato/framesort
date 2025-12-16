---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsEnumerable = addon.Collections.Enumerable
---@class UnitUtil
local M = {}
addon.WoW.Unit = M

local allPartyUnitsIds = {
    "player",
}
local allRaidUnitsIds = {}
local allEnemyUnitsIds = {}

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
    allEnemyUnitsIds[#allEnemyUnitsIds + 1] = "arena" .. i
end

for i = 1, maxArena do
    allEnemyUnitsIds[#allEnemyUnitsIds + 1] = "arenapet" .. i
end

function M:ArenaUnitProbablyExists(unit)
    -- after the gates open UnitExists will start working
    if wow.UnitExists(unit) then
        return true
    end

    -- get the number from the token, e.g. "2" from "arena2"
    local idStr = string.match(unit, "%d+")
    if not idStr then
        return false
    end

    -- if only 2 members load in a 3v3, then not all information is available
    -- e.g. in a 2v2, 2v3, or 3v2 inside a 3v3 environment GetNumArenaOpponentSpecs() doesn't return the right value
    local arenaCount = wow.GetNumArenaOpponentSpecs() or 0
    local groupCount = wow.GetNumGroupMembers() or 0
    local bgCount = 0

    if wow.IsInstanceBattleground() or (wow.C_PvP.IsInBrawl and wow.C_PvP.IsInBrawl()) then
        -- in 15v15 brawl, GetNumArenaOpponentSpecs returns 0 so we use GetNumBattlefieldScores instead
        bgCount = wow.GetNumBattlefieldScores() or 0
    end

    local instanceSize = math.max(arenaCount, groupCount, bgCount)

    local id = tonumber(idStr)
    return id <= instanceSize
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
            return wow.UnitExists(unit)
        end)
        :ToTable()
end

---Returns a table of enemy unit tokens where the unit exists.
---@return string[]
function M:EnemyUnits()
    local inInstance, instanceType = wow.IsInInstance()

    if not inInstance or instanceType ~= "arena" then
        return {}
    end

    return fsEnumerable
        :From(allEnemyUnitsIds)
        :Where(function(unit)
            return M:ArenaUnitProbablyExists(unit)
        end)
        :ToTable()
end

---Returns true if the unit token is a pet.
---@param unit string
function M:IsPet(unit)
    return unit ~= nil and string.find(unit, "pet", nil, true) ~= nil
end

---Returns the pet unit for the specified unit.
---@param unit string
---@param isEnemy boolean? pass true if unit is an enemy, used to avoid comparing secret values.
---@return string
function M:PetFor(unit, isEnemy)
    if not unit or unit == "" or unit == "none" then
        return "none"
    end

    -- isEnemy used here as UnitIsUnit returns a secret value for enemy units (e.g. arena123)
    local isPlayer = not isEnemy and M:IsPlayer(unit)

    if unit == "player" or isPlayer then
        return "pet"
    end

    local pet, _ = string.gsub(unit, "%a+", "%1pet")
    return pet
end

---Returns the parent token of a given pet unit, e.g. arenapet3 becomes arena3
---@param petUnit any
---@return string
function M:PetParent(petUnit)
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
    local isPlayerMaybeSecret = wow.UnitIsUnit(unit, "player")

    if wow.issecretvalue(isPlayerMaybeSecret) then
        return false
    end

    return isPlayerMaybeSecret
end

---Returns true if the unit is friendly to the current player.
---@param unit string
function M:IsFriendlyUnit(unit)
    return wow.UnitIsFriend("player", unit)
end

---Returns true if the unit is an enemy of the current player.
---@param unit string
function M:IsEnemyUnit(unit)
    return wow.UnitIsEnemy("player", unit)
end
