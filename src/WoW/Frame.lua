---@type string, Addon
local _, addon = ...
local fsEnumerable = addon.Collections.Enumerable
local fsCompare = addon.Collections.Comparer
local fsMath = addon.Numerics.Math
---@class FrameUtil
local M = {}

addon.WoW.Frame = M

---Returns the frames in order of their relative positioning to each other.
---@param frames table[] frames in any particular order
---@return FrameChain root in order of parent -> child -> child -> child
function M:ToFrameChain(frames)
    local invalid = { Valid = false }

    if #frames == 0 then
        return invalid
    end

    local nodesByFrame = fsEnumerable:From(frames):ToLookup(function(frame)
        return frame
    end, function(frame)
        return {
            Next = nil,
            Previous = nil,
            Value = frame,
        }
    end)

    local root = nil
    for _, child in pairs(nodesByFrame) do
        local _, relativeTo, _, _, _ = child.Value:GetPoint()
        local parent = nodesByFrame[relativeTo]

        if parent then
            if parent.Next then
                return invalid
            end

            parent.Next = child
            child.Previous = parent
        else
            root = child
        end
    end

    -- assert we have a complete chain
    local count = 0
    local current = root

    while current do
        count = count + 1
        current = current.Next
    end

    if count ~= #frames then
        return invalid
    end

    assert(root ~= nil)

    root.Valid = true
    return root
end

---Returns an ordered set of frames from the given chain
---@param chain FrameChain root
function M:FramesFromChain(chain)
    local frames = {}
    local next = chain

    while next do
        frames[#frames + 1] = next.Value

        ---@diagnostic disable-next-line: cast-local-type
        next = next.Next
    end

    return frames
end

---Returns true if all the frames have the same anchor.
---@param frames table[] frames in any particular order
---@return boolean
function M:IsFlat(frames)
    if #frames == 0 then
        return false
    end

    local _, anchor, _, _, _ = frames[1]:GetPoint()
    for i = 2, #frames do
        local _, relativeTo, _, _, _ = frames[i]:GetPoint()

        if relativeTo ~= anchor then
            return false
        end
    end

    return true
end

---Returns true if the specified frame is a valid unit frame.
---@param frame table
---@param getUnit fun(frame: table): string
---@return boolean
function M:IsValidUnitFrame(frame, getUnit)
    if not frame then
        return false
    end

    if type(frame) ~= "table" then
        return false
    end

    if frame:IsForbidden() then
        return false
    end

    if frame:GetTop() == nil or frame:GetLeft() == nil then
        return false
    end

    local unit = getUnit(frame)
    return unit ~= nil
end

---Returns a collection of unit frames from the specified container.
---@param container table
---@param getUnit fun(frame: table): string
---@return table
function M:ChildUnitFrames(container, getUnit)
    if not container or container:IsForbidden() or not container:IsVisible() then
        return {}
    end

    return fsEnumerable
        :From({ container:GetChildren() })
        :Where(function(frame)
            return M:IsValidUnitFrame(frame, getUnit)
        end)
        :ToTable()
end

---Returns the width x height of the frames in a grid layout.
---@return number width, number height
function M:GridSize(frames)
    if #frames == 0 then return 0, 0 end
    if #frames == 1 then return 1, 1 end

    local width = 1
    local height = 1

    local byCol = fsEnumerable:From(frames)
        :OrderBy(function(x, y) return fsCompare:CompareLeftTopFuzzy(x, y) end)
        :ToTable()

    local columnHeight = 1
    for i = 2, #byCol do
        local frame = byCol[i]
        local previous = byCol[i - 1]
        local sameColumn = fsMath:Round(frame:GetLeft()) == fsMath:Round(previous:GetLeft())

        if sameColumn then
            columnHeight = columnHeight + 1
            height = math.max(height, columnHeight)
        else
            columnHeight = 0
        end
    end

    local byRow = fsEnumerable:From(frames)
        :OrderBy(function(x, y) return fsCompare:CompareTopLeftFuzzy(x, y) end)
        :ToTable()

    local rowWidth = 1
    for i = 2, #byRow do
        local frame = byRow[i]
        local previous = byRow[i - 1]
        local sameRow = fsMath:Round(frame:GetTop()) == fsMath:Round(previous:GetTop())

        if sameRow then
            rowWidth = rowWidth + 1
            width = math.max(width, rowWidth)
        else
            rowWidth = 0
        end
    end

    return width, height
end
