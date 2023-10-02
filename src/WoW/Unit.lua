---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsEnumerable = addon.Collections.Enumerable
---@class UnitUtil
local M = {}
addon.WoW.Unit = M

local allPartyUnitsIds = {
    "player"
}
local allRaidUnitsIds = {}
local allEnemyUnitsIds = {}

for i = 1, wow.MEMBERS_PER_RAID_GROUP do
    allPartyUnitsIds[#allPartyUnitsIds + 1] = "party" .. i
end

for i = 1, wow.MEMBERS_PER_RAID_GROUP do
    allPartyUnitsIds[#allPartyUnitsIds + 1] = "partypet" .. i
end

for i = 1, wow.MAX_RAID_MEMBERS do
    allRaidUnitsIds[#allRaidUnitsIds + 1] = "raid" .. i
end

for i = 1, wow.MAX_RAID_MEMBERS do
    allRaidUnitsIds[#allRaidUnitsIds + 1] = "raidpet" .. i
end

for i = 1, wow.MEMBERS_PER_RAID_GROUP do
    allEnemyUnitsIds[#allEnemyUnitsIds + 1] = "arena" .. i
end

for i = 1, wow.MEMBERS_PER_RAID_GROUP do
    allEnemyUnitsIds[#allEnemyUnitsIds + 1] = "arenapet" .. i
end

---Gets a table of group member unit tokens.
---@return string[]
function M:FriendlyUnits(existsOnly)
    if existsOnly == nil then
        existsOnly = true
    end

    local isRaid = wow.IsInRaid()
    local units = isRaid and allRaidUnitsIds or allPartyUnitsIds

    if not existsOnly then
        -- return a copy of the table 
        -- to avoid any issues with the caller changing the table
        return wow.CopyTable(units)
    end

    if not wow.IsInGroup() then
        return { "player" }
    end

    return fsEnumerable
        :From(units)
        :Where(function(unit) return wow.UnitIsUnit(unit, "player") or wow.UnitExists(unit) end)
        :ToTable()
end

---Gets a table of enemy unit tokens.
---@return string[]
function M:EnemyUnits(existsOnly)
    if existsOnly == nil then
        existsOnly = true
    end

    if not existsOnly then
        return wow.CopyTable(allEnemyUnitsIds);
    end

    return fsEnumerable
        :From(allEnemyUnitsIds)
        :Where(function(unit) return wow.UnitExists(unit) end)
        :ToTable()
end

---Returns true if the unit token is a pet.
---@param unit string
function M:IsPet(unit)
    return string.match(unit, ".*pet.*") ~= nil
end
