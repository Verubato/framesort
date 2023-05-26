local _, addon = ...
local M = {}
addon.Point = M

---@class Point
---@field point string
---@field relativeTo table
---@field relativePoint string
---@field offsetX number?
---@field offsetY number?

---Returns the name values from frame:GetPoint()
---@param frame table
---@return Point point
function M:GetPointEx(frame)
    local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint()

    return {
        point = point,
        relativeTo = relativeTo,
        relativePoint = relativePoint,
        offsetX = offsetX,
        offsetY = offsetY
    }
end

---Returns the relative top left offset of the specified frame to the parent.
---@param child table the child frame
---@param parent table the parent frame
---@return integer top
---@return integer left
function M:RelativeTopLeft(child, parent)
    local top = (child:GetTop() or 0) - (parent:GetTop() or 0)
    local left = (child:GetLeft() or 0) - (parent:GetLeft() or 0)

    return top, left
end
