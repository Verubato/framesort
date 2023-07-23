local _, addon = ...
local fsEnumerable = addon.Enumerable
local M = {}
addon.Macro = M

local WowRole = {
    Tank = "TANK",
    Healer = "HEALER",
    DPS = "DAMAGER"
}

---Returns the start and end index of the nth "@" selector, e.g. @raid1, @player, @placeholder, @, @abc
---@param str string
---@param occurrence number? the nth occurrence to find
---@return number? start, number? end
local function NthSelector(str, occurrence)
    local startPos = nil
    local endPos = nil
    local n = 0

    -- find the nth "@"
    while n < occurrence do
        n = n + 1

        startPos, endPos = string.find(str, "@", endPos and endPos + 1 or nil)
        if not startPos or not endPos then
            return nil, nil
        end
    end

    local unitStartPos, unitEndPos = string.find(str, "^%w+", endPos + 1)
    if unitStartPos and unitEndPos then
        -- return the start pos of "@"
        -- and the end pos of the unit
        return startPos, unitEndPos
    end

    return startPos, endPos
end

---Replaces all, or the nth occurrence of an "@unit" instance with the specified unit
---@param body string
---@param unit string
---@param occurrence number? the nth selector to replace, or all selectors if this is nil.
---@return string? the new body text, or nil if invalid
local function ReplaceSelector(body, unit, occurrence)
    local startPos = nil
    local endPos = nil

    if occurrence then
        startPos, endPos = NthSelector(body, occurrence)
        if not startPos or not endPos then
            return body
        end

        local newBody = string.sub(body, 0, startPos)
        newBody = newBody .. unit
        newBody = newBody .. string.sub(body, endPos + 1)
        return newBody
    else
        local n = 1
        local newBody = body
        startPos, endPos = NthSelector(newBody, n)

        if not startPos or not endPos then
            return nil
        end

        while startPos and endPos do
            local replaced = string.sub(newBody, 0, startPos)
            replaced = replaced .. unit
            replaced = replaced .. string.sub(newBody, endPos + 1)
            newBody = replaced

            n = n + 1
            startPos, endPos = NthSelector(newBody, n)
        end

        return newBody
    end
end

local function GetSelectors(body)
    local header = string.match(body, "[Ff][Rr][Aa][Mm][Ee][Ss][Oo][Rr][Tt].-\n")
    local selectors = {}

    if not header then
        return selectors
    end

    -- basically string split on non-alpha characters
    local passedHeader = false
    for match in string.gmatch(header, "([%w]+)") do
        if passedHeader then
            selectors[#selectors + 1] = match
        end

        -- skip the "#framesort" header
        passedHeader = true
    end

    return selectors
end

local function UnitForSelector(selector, friendlyUnits)
    if not IsInGroup() then
        return "none"
    end

    local selectorLower = string.lower(selector)
    local numberStr = string.match(selector, "%d+")
    local number = numberStr and tonumber(numberStr) or nil

    -- frame
    if string.match(selectorLower, "frame") then
        return number and friendlyUnits[number] or "none"
    end

    local tank = string.match(selectorLower, "tank")
    local healer = string.match(selectorLower, "healer")
    local dps = string.match(selectorLower, "dps")

    -- enemy arena
    if string.match(selectorLower, "enemy") then
        local count = GetNumArenaOpponentSpecs()
        if not count or count <= 0 then
            return "none"
        end

        local ids = {}
        for i = 1, count do
            ids[#ids + 1] = i
        end

        local arenaId = fsEnumerable:From(ids):Nth(number or 1, function(x)
            local specId = GetArenaOpponentSpec(x)
            local _, _, _, _, role, _, _ = GetSpecializationInfoByID(specId)

            return (tank and role == WowRole.Tank) or (healer and role == WowRole.Healer) or (dps and role == WowRole.DPS)
        end)

        if arenaId then
            return "arena" .. arenaId
        end

        return "none"
    end

    -- tank
    local role = nil
    if tank then
        role = WowRole.Tank
    elseif healer then
        role = WowRole.Healer
    elseif dps then
        role = WowRole.DPS
    end

    -- role
    if role then
        return fsEnumerable:From(friendlyUnits):Nth(number or 1, function(x)
            return UnitGroupRolesAssigned(x) == role
        end) or "none"
    end

    return selector
end

function M:IsFrameSortMacro(body)
    return body and string.match(body, "[Ff][Rr][Aa][Mm][Ee][Ss][Oo][Rr][Tt]") ~= nil or false
end

---Returns a copy of the macro body with the new unit inserted.
---@param body string the current macro body.
---@param units string[] sorted unit ids.
---@return string? the new macro body, or nil if invalid
function M:GetNewBody(body, units)
    local newBody = body
    local selectors = GetSelectors(body)

    for i, selector in ipairs(selectors) do
        local unit = UnitForSelector(selector, units)
        local tmp = ReplaceSelector(newBody, unit, #selectors > 1 and i or nil)

        if not tmp then
            return nil
        else
            newBody = tmp
        end
    end

    return newBody
end
