-- a dummy table that just accepts everything and does nothing
local void = {}
setmetatable(void, {
    __index = function(table, key)
        table[key] = function()
            return table
        end

        return table[key]
    end,
})

local M = {}

setmetatable(M, { __index = void })

function M:New(type, name, parent, template)
    local frame = {
        State = {
            ScriptHooks = {},
            EventRegistrations = {},
            Attributes = {},
            AttributeDrivers = {},
            Text = "",
            Visible = true,
            Point = {
                Point = nil,
                RelativeTo = nil,
                RelativePoint = nil,
                XOffset = 0,
                YOffset = 0,
            },
            Position = {
                Top = 0,
                Left = 0,
                Right = 0,
                Bottom = 0,
            },
            Children = {}
        },
        Type = type,
        -- don't want name to be nil otherwise the void metatable will kick in and return a black hole
        Name = name or false,
        Parent = parent,
        Template = template,
    }

    -- set the text object to the frame itself
    -- so when code accesses frame.Text:SetText() it's just calling itself
    frame.Text = frame

    setmetatable(frame, {
        __index = M,
    })

    if parent then
        parent.State.Children[#parent.State.Children + 1] = frame
    end

    return frame
end

function M:IsForbidden()
    return false
end

function M:GetName()
    return self.Name and self.Name or nil
end

function M:SetAttribute(name, value)
    self.State.Attributes[name] = value
end

function M:GetAttribute(name)
    return self.State.Attributes[name]
end

function M:SetText(value)
    self.State.Text = value
end

function M:HookScript(event, callback)
    self.State.ScriptHooks[#self.State.ScriptHooks + 1] = {
        Event = event,
        Callback = callback,
    }
end

function M:RegisterEvent(event)
    self.State.EventRegistrations[#self.State.EventRegistrations + 1] = event
end

function M:GetPoint()
    local pos = self.State.Point
    return pos.Point, pos.RelativeTo, pos.RelativePoint, pos.XOffset, pos.YOffset
end

function M:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
    local pos = self.State.Point
    pos.Point = point
    pos.RelativeTo = relativeTo
    pos.RelativePoint = relativePoint
    pos.XOffset = xOffset
    pos.YOffset = yOffset
end

function M:SetPosition(top, left, right, bottom)
    local pos = self.State.Position
    pos.Top = top
    pos.Left = left
    pos.Right = right
    pos.Bottom = bottom
end

function M:AdjustPointsOffset(x, y)
    local point = self.State.Point
    point.YOffset = point.YOffset + y
    point.XOffset = point.XOffset + x

    local pos = self.State.Position
    pos.Top = pos.Top + y
    pos.Bottom = pos.Bottom + y
    pos.Left = pos.Left + x
    pos.Right = pos.Right + x
end

function M:GetLeft()
    return self.State.Position.Left
end

function M:GetHeight()
    return self.State.Position.Top - self.State.Position.Bottom
end

function M:GetWidth()
    return self.State.Position.Right - self.State.Position.Left
end

function M:GetTop()
    return self.State.Position.Top
end

function M:GetBottom()
    return self.State.Position.Bottom
end

function M:IsVisible()
    return self.State.Visible
end

function M:Show()
    self.State.Visible = true
end

function M:Hide()
    self.State.Visible = false
end

function M:GetChildren()
    return unpack(self.State.Children)
end

function M:FireEvent(event, ...)
    local registered = false
    for _, registration in ipairs(self.State.EventRegistrations) do
        if registration == event then
            registered = true
            break
        end
    end

    if not registered then
        return
    end

    for _, hook in ipairs(self.State.ScriptHooks) do
        if hook.Event == "OnEvent" then
            hook.Callback(self, event, ...)
        end
    end
end

-- the slider low/high labels are accessed via the global table
-- so put some dummy values in there
_G["sldPartyXSpacingLow"] = void
_G["sldPartyXSpacingHigh"] = void
_G["sldPartyYSpacingLow"] = void
_G["sldPartyYSpacingHigh"] = void

_G["sldRaidXSpacingLow"] = void
_G["sldRaidXSpacingHigh"] = void
_G["sldRaidYSpacingLow"] = void
_G["sldRaidYSpacingHigh"] = void

_G["sldEnemy ArenaXSpacingLow"] = void
_G["sldEnemy ArenaXSpacingHigh"] = void
_G["sldEnemy ArenaYSpacingLow"] = void
_G["sldEnemy ArenaYSpacingHigh"] = void

return M
