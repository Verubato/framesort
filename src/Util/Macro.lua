local _, addon = ...
local macro = {}
addon.Macro = macro

---Returns the start and end index of the nth "@" selector, e.g. @raid1, @player, @placeholder, @, @abc
---@param str string
---@param occurrence number? the nth occurrence to find
---@return number? start, number? end
local function NthFrameSelector(str, occurrence)
    local startPos = nil
    local endPos = nil
    local n = 0

    -- find the nth "@"
    while n < occurrence do
        n = n + 1

        startPos, endPos = string.find(str, "@", endPos and endPos + 1 or nil)
        if not startPos or not endPos then return nil, nil end
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
local function ReplaceUnitSelector(body, unit, occurrence)
    local startPos = nil
    local endPos = nil

    if occurrence then
        startPos, endPos = NthFrameSelector(body, occurrence)
        if not startPos or not endPos then error(occurrence) end

        local newBody = string.sub(body, 0, startPos)
        newBody = newBody .. unit
        newBody = newBody .. string.sub(body, endPos + 1)
        return newBody
    else
        local n = 1
        local newBody = body
        startPos, endPos = NthFrameSelector(newBody, n)

        if not startPos or not endPos then return nil end

        while startPos and endPos do
            local replaced = string.sub(newBody, 0, startPos)
            replaced = replaced .. unit
            replaced = replaced .. string.sub(newBody, endPos + 1)
            newBody = replaced

            n = n + 1
            startPos, endPos = NthFrameSelector(newBody, n)
        end

        return newBody
    end
end

---Returns true if the macro is one that FrameSort should update.
function macro:IsFrameSortMacro(body)
    return body and string.match(body, "[Ff]rame[Ss]ort") ~= nil or false
end

---Extracts the frame numbers from the macro body.
function macro:GetFrameIds(body)
    local ids = {}

    for match in string.gmatch(body, "[^@][Ff]rame%d+") do
        local number = string.match(match, "%d+")
        ids[#ids + 1] = tonumber(number)
    end

    return ids
end

---Returns a copy of the macro body with the new unit inserted.
---@param body string the current macro body.
---@param ids table<number> frame ids
---@param units table<string> sorted unit ids.
---@return string? the new macro body, or nil if invalid
function macro:GetNewBody(body, ids, units)
    local newBody = body

    for i, id in ipairs(ids) do
        local unit = (IsInGroup() and units[id]) or "none"
        local tmp = ReplaceUnitSelector(newBody, unit, #ids > 1 and i or nil)

        if not tmp then
            return nil
        else
            newBody = tmp
        end
    end

    return newBody
end
