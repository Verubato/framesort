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

local M = {
    GetName = function(self)
        return self.Name
    end,
}

setmetatable(M, { __index = void })

function M:New(type, name, parent, template)
    local frame = {
        State = {
            ScriptHooks = {},
            EventRegistrations = {},
            Attributes = {},
            Text = "",
        },
        Type = type,
        Name = name,
        Parent = parent,
        Template = template,
    }

    -- set the text object to the frame itself
    -- so when code accesses frame.Text:SetText() it's just calling itself
    frame.Text = frame

    setmetatable(frame, {
        __index = M,
    })

    return frame
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
            hook.Callback(...)
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
