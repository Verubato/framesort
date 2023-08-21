---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
---@class UnitUtil
local M = {}
addon.WoW.Unit = M

---Gets a table of group member unit tokens that exist (UnitExists()).
---@return string[]
function M:FriendlyUnits()
    local members = {}

    if not wow.IsInGroup() then
        return members
    end

    local isRaid = wow.IsInRaid()
    local prefix = isRaid and "raid" or "party"
    local toGenerate = isRaid and wow.MAX_RAID_MEMBERS or (wow.MEMBERS_PER_RAID_GROUP - 1)

    -- raids don't have the "player" token frame
    if not isRaid then
        table.insert(members, "player")
    end

    for i = 1, toGenerate do
        local unit = prefix .. i
        if wow.UnitExists(unit) then
            table.insert(members, unit)
        end
    end

    return members
end

---Gets a table of enemy unit tokens that may or may not exist.
---@return string[]
function M:EnemyUnits()
    local members = {}
    local prefix = "arena"
    local toGenerate = 5

    for i = 1, toGenerate do
        local unit = prefix .. i
        table.insert(members, unit)
    end

    return members
end

---Returns true if the unit token is a pet.
---@param unit string
function M:IsPet(unit)
    return string.match(unit, ".*pet.*") ~= nil
end