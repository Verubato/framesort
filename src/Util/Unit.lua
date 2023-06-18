local _, addon = ...
local fsEnumerable = addon.Enumerable
local M = {}
addon.Unit = M

---Gets a table of group member unit tokens that exist (UnitExists()).
---@return string[]
function M:GetUnits()
    local isRaid = IsInRaid()
    local prefix = isRaid and "raid" or "party"
    local toGenerate = isRaid and MAX_RAID_MEMBERS or (MEMBERS_PER_RAID_GROUP - 1)
    local members = {}

    -- raids don't have the "player" token frame
    if not isRaid then
        table.insert(members, "player")
    end

    for i = 1, toGenerate do
        local unit = prefix .. i
        if UnitExists(unit) then
            table.insert(members, unit)
        end
    end

    return members
end

---Gets the pet units for the specified player units.
---@param units string[]
---@return string[] pet unit tokens
function M:GetPets(units)
    return fsEnumerable
        :From(units)
        :Map(function(x) return x .. "pet" end)
        :Where(function(x) return UnitExists(x) end)
        :ToTable()
end

---Returns true if the unit token is a pet.
---@param unit string
function M:IsPet(unit)
    return string.match(unit, ".*pet.*") ~= nil
end

---Returns true if the unit token is a person/human.
---@param unit string
function M:IsPlayer(unit)
    return UnitIsPlayer(unit)
end
