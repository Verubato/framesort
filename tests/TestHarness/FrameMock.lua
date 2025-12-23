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

local function getPointXY(frame, point)
    local pos = frame.State.Position
    local left, right, top, bottom = pos.Left, pos.Right, pos.Top, pos.Bottom
    point = point or "TOPLEFT"

    if point == "TOPLEFT" then
        return left, top
    elseif point == "TOP" then
        return (left + right) / 2, top
    elseif point == "TOPRIGHT" then
        return right, top
    elseif point == "LEFT" then
        return left, (top + bottom) / 2
    elseif point == "CENTER" then
        return (left + right) / 2, (top + bottom) / 2
    elseif point == "RIGHT" then
        return right, (top + bottom) / 2
    elseif point == "BOTTOMLEFT" then
        return left, bottom
    elseif point == "BOTTOM" then
        return (left + right) / 2, bottom
    elseif point == "BOTTOMRIGHT" then
        return right, bottom
    end

    return left, top
end

local function applyPointToPosition(frame, point, absX, absY)
    local pos = frame.State.Position
    local size = frame.State.Size

    local w = (size and size.Width) or (pos.Right - pos.Left)
    local h = (size and size.Height) or (pos.Top - pos.Bottom)

    if (not w or not h) or (w == 0 and h == 0) then
        return
    end

    if point == "TOPLEFT" then
        pos.Left = absX
        pos.Top = absY
        pos.Right = absX + w
        pos.Bottom = absY - h
    elseif point == "TOPRIGHT" then
        pos.Right = absX
        pos.Top = absY
        pos.Left = absX - w
        pos.Bottom = absY - h
    elseif point == "BOTTOMLEFT" then
        pos.Left = absX
        pos.Bottom = absY
        pos.Right = absX + w
        pos.Top = absY + h
    elseif point == "BOTTOMRIGHT" then
        pos.Right = absX
        pos.Bottom = absY
        pos.Left = absX - w
        pos.Top = absY + h
    elseif point == "TOP" then
        pos.Left = absX - w / 2
        pos.Right = absX + w / 2
        pos.Top = absY
        pos.Bottom = absY - h
    elseif point == "BOTTOM" then
        pos.Left = absX - w / 2
        pos.Right = absX + w / 2
        pos.Bottom = absY
        pos.Top = absY + h
    elseif point == "LEFT" then
        pos.Left = absX
        pos.Right = absX + w
        pos.Top = absY + h / 2
        pos.Bottom = absY - h / 2
    elseif point == "RIGHT" then
        pos.Right = absX
        pos.Left = absX - w
        pos.Top = absY + h / 2
        pos.Bottom = absY - h / 2
    elseif point == "CENTER" then
        pos.Left = absX - w / 2
        pos.Right = absX + w / 2
        pos.Top = absY + h / 2
        pos.Bottom = absY - h / 2
    else
        assert(false)
    end
end

local function isFrameLike(rel)
    if type(rel) ~= "table" then
        return false
    end
    local st = rawget(rel, "State")
    if type(st) ~= "table" then
        return false
    end
    if type(rawget(st, "Position")) ~= "table" then
        return false
    end
    return true
end

local function removeDependent(parent, child)
    if not isFrameLike(parent) then
        return
    end
    local deps = parent.State.Dependents
    if type(deps) ~= "table" then
        return
    end
    for i = #deps, 1, -1 do
        if deps[i] == child then
            table.remove(deps, i)
        end
    end
end

local function addDependent(parent, child)
    if not isFrameLike(parent) then
        return
    end
    local deps = parent.State.Dependents
    if type(deps) ~= "table" then
        parent.State.Dependents = {}
        deps = parent.State.Dependents
    end
    deps[#deps + 1] = child
end

-- Recompute this frame's absolute position from its stored anchor.
-- Then propagate to dependents (frames anchored to this frame).
local function recomputeFromAnchor(frame, visited)
    if not isFrameLike(frame) then
        return
    end

    visited = visited or {}
    if visited[frame] then
        return
    end
    visited[frame] = true

    local p = frame.State.Point
    if p and p.Point and isFrameLike(p.RelativeTo) and p.RelativePoint then
        local baseX, baseY = getPointXY(p.RelativeTo, p.RelativePoint)
        local absX = baseX + (p.XOffset or 0)
        local absY = baseY + (p.YOffset or 0)
        applyPointToPosition(frame, p.Point, absX, absY)
    end

    local deps = frame.State.Dependents
    if type(deps) == "table" then
        for i = 1, #deps do
            recomputeFromAnchor(deps[i], visited)
        end
    end
end

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
            Size = {
                Width = 0,
                Height = 0,
            },
            Children = {},
            Dependents = {}, -- frames anchored to this frame
            Forbidden = false,
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
    return self.State.Forbidden
end

function M:GetName()
    return self.Name and self.Name or nil
end

function M:SetName(name)
    self.Name = name
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

function M:SetScript(event, callback)
    self:HookScript(event, callback)
end

function M:RegisterEvent(event)
    self.State.EventRegistrations[#self.State.EventRegistrations + 1] = event
end

function M:GetPoint()
    local pos = self.State.Point
    return pos.Point, pos.RelativeTo, pos.RelativePoint, pos.XOffset, pos.YOffset
end

function M:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
    local p = self.State.Point

    -- unlink from old relativeTo dependents
    if isFrameLike(p.RelativeTo) then
        removeDependent(p.RelativeTo, self)
    end

    p.Point = point
    p.RelativeTo = relativeTo
    p.RelativePoint = relativePoint
    p.XOffset = xOffset or 0
    p.YOffset = yOffset or 0

    -- link to new relativeTo dependents
    if isFrameLike(relativeTo) then
        addDependent(relativeTo, self)
    end

    -- recompute our position from the anchor (if possible), then propagate
    recomputeFromAnchor(self)
end

function M:SetSize(width, height)
    local size = self.State.Size
    size.Width = width
    size.Height = height

    -- If we have an anchor, recompute from it (and propagate)
    local p = self.State.Point
    if p and p.Point and isFrameLike(p.RelativeTo) and p.RelativePoint then
        recomputeFromAnchor(self)
        return
    end

    -- Otherwise, keep current Top/Left as the stable corner,
    -- and update Right/Bottom from width/height.
    local pos = self.State.Position
    pos.Right = pos.Left + width
    pos.Bottom = pos.Top - height

    -- and propagate to any dependents anchored to us
    local deps = self.State.Dependents
    if type(deps) == "table" then
        for i = 1, #deps do
            recomputeFromAnchor(deps[i])
        end
    end
end

function M:AdjustPointsOffset(x, y)
    x = x or 0
    y = y or 0

    -- Adjust stored offsets
    local point = self.State.Point
    point.YOffset = (point.YOffset or 0) + y
    point.XOffset = (point.XOffset or 0) + x

    -- Move our absolute rect
    local pos = self.State.Position
    pos.Top = pos.Top + y
    pos.Bottom = pos.Bottom + y
    pos.Left = pos.Left + x
    pos.Right = pos.Right + x

    -- Any frames anchored to us should update (WoW-style propagation)
    local deps = self.State.Dependents
    if type(deps) == "table" then
        for i = 1, #deps do
            recomputeFromAnchor(deps[i])
        end
    end
end

function M:GetLeft()
    return self.State.Position.Left
end

function M:GetRight()
    return self.State.Position.Right
end

function M:GetRect()
    local left = self:GetLeft()
    local bottom = self:GetBottom()
    local width = self:GetWidth()
    local height = self:GetHeight()
    return left, bottom, width, height
end

function M:GetHeight()
    return self.State.Size.Height
end

function M:GetWidth()
    return self.State.Size.Width
end

function M:GetTop()
    return self.State.Position.Top
end

function M:GetBottom()
    return self.State.Position.Bottom
end

function M:ClearAllPoints()
    local p = self.State.Point

    -- unlink from old relativeTo dependents
    if isFrameLike(p.RelativeTo) then
        removeDependent(p.RelativeTo, self)
    end

    p.Point = nil
    p.RelativeTo = nil
    p.RelativePoint = nil
    p.XOffset = 0
    p.YOffset = 0
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
