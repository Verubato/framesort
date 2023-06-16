local _, addon = ...
local memberUnitPatterns = {
    "^player$",
    "^party%d$",
    "^raid%d$",
    "^raid%d%d$",
}
local petUnitPatterns = {
    "^pet$",
    "^playerpet$",
    "^party%dpet$",
    "^partypet%d$",
    "^raidpet%d$",
    "^raidpet%d%d$",
    "^raid%dpet$",
    "^raid%d%dpet$"
}

local fsEnumerable = addon.Enumerable
local M = {}
addon.Unit = M

---Gets a table of group member unit tokens that exist (UnitExists()).
---@return table<string>
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
---@param units table<string>
---@return table<string> pet unit tokens
function M:GetPets(units)
    return fsEnumerable
        :From(units)
        :Map(function(x) return x .. "pet" end)
        :Where(function(x) return UnitExists(x) end)
        :ToTable()
end

---Determines if the unit token is a pet.
---@param unit string
---@return boolean true if the unit is a pet, otherwise false.
function M:IsPet(unit)
    return fsEnumerable
        :From(petUnitPatterns)
        :Any(function(pattern) return string.match(unit, pattern) ~= nil end)
end

---Determines if the unit token is a person/member/human.
---@param unit string
---@return boolean true if the unit is a member, otherwise false.
function M:IsMember(unit)
    return fsEnumerable
        :From(memberUnitPatterns)
        :Any(function(pattern) return string.match(unit, pattern) ~= nil end)
end
