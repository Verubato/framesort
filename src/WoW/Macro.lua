---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsEnumerable = addon.Collections.Enumerable
---@class MacroUtil
local M = {}
addon.WoW.Macro = M

local shortSyntax = "@"
local longSyntax = "target="
local alphanumericWord = "([%w]+)"
local shortPattern = shortSyntax .. alphanumericWord
local longPattern = longSyntax .. alphanumericWord

local WowRole = {
    Tank = "TANK",
    Healer = "HEALER",
    DPS = "DAMAGER",
}

---Returns the start and end index of the nth target selector, e.g. @raid1, @player, @placeholder, target=player
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

        local shortStartPos, shortEndPos = string.find(str, shortPattern, endPos and endPos + 1 or nil)
        local longStartPos, longEndPos = string.find(str, longPattern, endPos and endPos + 1 or nil)

        -- check to see which selector comes first in the macro
        -- return the earliest
        if shortStartPos and shortStartPos <= (longStartPos or shortStartPos) then
            startPos = shortStartPos
            endPos = shortEndPos
        elseif longStartPos and longStartPos <= (shortStartPos or longStartPos) then
            -- skip past the "target=" to the unit
            longStartPos = longStartPos + string.len(longSyntax) - 1

            startPos = longStartPos
            endPos = longEndPos
        else
            return nil, nil
        end
    end

    return startPos, endPos
end

---Replaces all, or the nth occurrence of an "@unit" instance with the specified unit
---@param body string
---@param unit string
---@param occurrence number the nth selector to replace
---@return string? the new body text, or nil if invalid
local function ReplaceSelector(body, unit, occurrence)
    local startPos = nil
    local endPos = nil

    startPos, endPos = NthSelector(body, occurrence)
    if not startPos or not endPos then
        return nil
    end

    local newBody = string.sub(body, 0, startPos)
    newBody = newBody .. unit
    newBody = newBody .. string.sub(body, endPos + 1)
    return newBody
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

local function UnitForSelector(selector, friendlyUnits, enemyUnits)
    local selectorLower = string.lower(selector)
    local numberStr = string.match(selector, "%d+")
    local number = numberStr and tonumber(numberStr) or nil

    -- bottom frame
    if string.match(selectorLower, "bottomframe") then
        return number and friendlyUnits[#friendlyUnits] or "none"
    end

    -- enemy frame
    if string.match(selectorLower, "enemyframe") then
        return number and enemyUnits[number] or "none"
    end

    -- frame
    if string.match(selectorLower, "frame") then
        return number and friendlyUnits[number] or "none"
    end

    local tank = string.match(selectorLower, "tank")
    local healer = string.match(selectorLower, "healer")
    local dps = string.match(selectorLower, "dps")

    -- enemy arena
    if string.match(selectorLower, "enemy") then
        if not wow.IsRetail() then
            return "none"
        end

        local count = wow.GetNumArenaOpponentSpecs()
        if not count or count <= 0 then
            return "none"
        end

        local ids = {}
        for i = 1, count do
            ids[#ids + 1] = i
        end

        local arenaId = fsEnumerable:From(ids):Nth(number or 1, function(x)
            local specId = wow.GetArenaOpponentSpec(x)
            local _, _, _, _, role, _, _ = wow.GetSpecializationInfoByID(specId)

            return (tank and role == WowRole.Tank) or (healer and role == WowRole.Healer) or (dps and role == WowRole.DPS)
        end)

        if arenaId then
            return "arena" .. arenaId
        end

        return "none"
    end

    -- other dps
    if string.match(selectorLower, "otherdps") then
        return fsEnumerable:From(friendlyUnits):Nth(number or 1, function(x)
            return wow.UnitGroupRolesAssigned(x) == WowRole.DPS and not wow.UnitIsUnit(x, "player")
        end) or "none"
    end

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
            return wow.UnitGroupRolesAssigned(x) == role
        end) or "none"
    end

    return selector
end

function M:IsFrameSortMacro(body)
    return body and string.match(body, "[Ff][Rr][Aa][Mm][Ee][Ss][Oo][Rr][Tt]") ~= nil or false
end

---Returns a copy of the macro body with the new unit inserted.
---@param body string the current macro body.
---@param friendlyUnits string[] sorted friendly unit ids.
---@param enemyUnits string[] sorted enemy unit ids.
---@return string? the new macro body, or nil if invalid
function M:GetNewBody(body, friendlyUnits, enemyUnits)
    local newBody = body
    local selectors = GetSelectors(body)

    for i, selector in ipairs(selectors) do
        local unit = UnitForSelector(selector, friendlyUnits, enemyUnits)
        local tmp = ReplaceSelector(newBody, unit, i)

        if tmp then
            newBody = tmp
        end
    end

    return newBody
end
