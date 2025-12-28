---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local wowEx = addon.WoW.WowEx
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

---@return string[]
local function ArenaUnits()
    local count = wowEx.ArenaOpponentsCount()

    if count == 0 then
        return {}
    end

    local units = {}

    for i = 1, count do
        units[#units + 1] = "arena" .. i
    end

    for i = 1, count do
        units[#units + 1] = "arenapet" .. i
    end

    return units
end

---@return string[]
local function BgUnits()
    local count = wow.GetNumBattlefieldScores()

    if count == 0 then
        return {}
    end

    local units = {}
    local playerFaction = wow.UnitFactionGroup("player")
    local playerFactionId = (playerFaction == "Alliance") and 1 or 0

    for i = 1, count do
        local name, _, _, _, _, faction = wow.GetBattlefieldScore(i)
        local isEnemy = faction ~= playerFactionId

        if isEnemy then
            units[#units + 1] = name
        end
    end

    return units
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

function M:BgEnemyUnitExists(unit)
    if not unit then
        fsLog:Bug("Unit:BgEnemyUnitExists() - unit must not be nil.")
        return false
    end

    local guid = wow.UnitGUID and wow.UnitGUID(unit)

    if guid and not wow.issecretvalue(guid) then
        local info = wow.C_PvP.GetScoreInfoByPlayerGuid(guid)
        return info ~= nil and info.name ~= nil
    end

    local count = wow.GetNumBattlefieldScores()

    if count == 0 then
        return {}
    end

    local playerFaction = wow.UnitFactionGroup("player")
    local playerFactionId = (playerFaction == "Alliance") and 1 or 0

    for i = 1, count do
        local name, _, _, _, _, faction = wow.GetBattlefieldScore(i)
        local isEnemy = faction ~= playerFactionId

        if isEnemy and name == unit then
            print("Found enemy exists from name")
            return true
        end
    end

    return false
end

function M:ArenaUnitExists(unit)
    if not unit then
        fsLog:Bug("Unit:ArenaEnemyUnitExists() - unit must not be nil.")
        return false
    end

    local arenaCount = wowEx.ArenaOpponentsCount()

    if arenaCount <= 0 then
        return false
    end

    -- get the number from the token, e.g. "2" from "arena2"
    local idStr = string.match(unit, "%d+")
    local id = idStr and tonumber(idStr)

    if not id then
        fsLog:Bug("Invalid arena unit %s.", unit)
        return false
    end

    -- don't use UnitExists because of a blizzard bug where arena4 and arenapet4 temporarily exist as enemies
    -- but they are actually ally units that are classified as enemies for a split second
    return id <= arenaCount
end

function M:EnemyUnitExists(unit)
    if not unit then
        fsLog:Bug("Unit:EnemyUnitExists() - unit must not be nil.")
        return false
    end

    if wowEx.IsInstanceArena() then
        return M:ArenaUnitExists(unit)
    end

    if wowEx.IsInstanceBattleground() or wowEx.IsInstanceBrawl() then
        return M:BgEnemyUnitExists(unit)
    end

    return false
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
---@return string[],string
function M:EnemyUnits()
    if wowEx.IsInstanceArena() then
        return ArenaUnits(), "arena"
    end

    if wowEx.IsInstanceBattleground() then
        return BgUnits(), "bg"
    end

    return {}, ""
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
