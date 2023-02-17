local _, addon = ...

-- returns a table of group member unit tokens that exist (UnitExists())
function addon:GetUnits()
    local isRaid = IsInRaid()
    local prefix = isRaid and "raid" or "party"
    local toGenerate = isRaid and MAX_RAID_MEMBERS or (MEMBERS_PER_RAID_GROUP - 1)
    local members = {}
    local count = 0

    -- raids don't have the "player" token
    if not isRaid then
        table.insert(members, "player")
        count = 1
    end

    for i = 1, toGenerate do
        local unit = prefix .. i
        if UnitExists(unit) then
            table.insert(members, unit)
            count = count + 1
        end
    end

    return members
end
