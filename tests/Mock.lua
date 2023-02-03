local M = {}

function M:GenerateUnits(size)
    local maxPartySize = 5
    local prefix = size > maxPartySize and "raid" or "party"
    local toGenerate = size > maxPartySize and size or (size - 1)
    local members = {}

    -- raids don't have the "player" token
    if size <= maxPartySize then
        table.insert(members, "player")
    end

    for i = 1,toGenerate do
        table.insert(members, prefix .. i)
    end

    return members
end

function M:UnitExists(unit, members)
    for _, x in pairs(members) do
        if x == unit then return true end
    end

    return false
end

return M
