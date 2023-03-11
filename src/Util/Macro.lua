local _, addon = ...
local macro = {}
addon.Macro = macro

---Returns the start and end index of the next "@" selector
---@param str string
---@param start number? optional starting index
---@return number start, number end
local function NextFrameSelector(str, start)
    local startPos = string.find(str, "@", start)
    local endPos = string.find(str, "[,%]]", startPos)

    return startPos, endPos
end

---Replaces all, or the nth occurrence of an "@unit" instance with the specified unit
---@param body string
---@param unit string
---@param occurrence number? the nth selector to replace, or all selectors if this is nil.
local function ReplaceUnitSelector(body, unit, occurrence)
    local startPos, endPos = NextFrameSelector(body, startPos)

    if occurrence then
        local n = 1
        while n < occurrence do
            n = n + 1
            startPos, endPos = NextFrameSelector(body, startPos + 1)
        end

        local newBody = string.sub(body, 0, startPos)
        newBody = newBody .. unit
        newBody = newBody .. string.sub(body, endPos)

        return newBody
    else
        local newBody = body
        while startPos do
            local replaced = string.sub(newBody, 0, startPos)
            replaced = replaced .. unit
            replaced = replaced .. string.sub(newBody, endPos)
            newBody = replaced

            startPos, endPos = NextFrameSelector(newBody, startPos + 1)
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

    for match in string.gmatch(body, "[Ff]rame%d+") do
        local number = string.match(match, "%d+")
        ids[#ids + 1] = tonumber(number)
    end

    return ids
end

---Returns a copy of the macro body with the new unit inserted.
---@param body string the current macro body.
---@param ids table<number> frame ids
---@param units table<string> sorted unit ids.
---@return string the new macro body
function macro:GetNewBody(body, ids, units)
    local newBody = body

    for i, id in ipairs(ids) do
        local unit = (IsInGroup() and units[id]) or "none"
        newBody = ReplaceUnitSelector(newBody, unit, #ids > 1 and i or nil)
    end

    return newBody
end
