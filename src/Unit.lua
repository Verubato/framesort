local _, addon = ...

---Gets a table of group member unit tokens that exist (UnitExists()).
---@return table
function addon:GetUnits()
    local isRaid = IsInRaid()
    local prefix = isRaid and "raid" or "party"
    local toGenerate = isRaid and MAX_RAID_MEMBERS or (MEMBERS_PER_RAID_GROUP - 1)
    local members = {}

    -- raids don't have the "player" token frane
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
