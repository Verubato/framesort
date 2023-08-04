local _, addon = ...
local M = {}
addon.Unit = M

---Gets a table of group member unit tokens that exist (UnitExists()).
---@return string[]
function M:GetUnits()
    local members = {}

    if not IsInGroup() then
        return members
    end

    local isRaid = IsInRaid()
    local prefix = isRaid and "raid" or "party"
    local toGenerate = isRaid and MAX_RAID_MEMBERS or (MEMBERS_PER_RAID_GROUP - 1)

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

---Returns true if the unit token is a pet.
---@param unit string
function M:IsPet(unit)
    return string.match(unit, ".*pet.*") ~= nil
end
