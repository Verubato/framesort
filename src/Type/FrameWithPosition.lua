local _, addon = ...

---@class FrameWithPosition
---@field Frame table the unit frame
---@field Points table the frame's position

---Converts a unit frame to a FrameWithPoints
---@param frame table
---@return FrameWithPosition
function addon:ToFrameWithPosition(frame)
    local data = {
        Frame = frame,
        Points = {}
    }

    local pointsCount = frame:GetNumPoints()
    for j = 1, pointsCount do
        data.Points[j] = { frame:GetPoint(j) }
    end

    return data
end
