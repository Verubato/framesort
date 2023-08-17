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
    ScriptHooks = {},
    EventRegistrations = {},
    Text = void,
    GetName = function()
        return "Frame"
    end,
}

_G["FrameLow"] = void
_G["FrameHigh"] = void

setmetatable(M, { __index = void })

function M:HookScript(event, callback)
    self.ScriptHooks[#self.ScriptHooks + 1] = {
        Event = event,
        Callback = callback,
    }
end

function M:RegisterEvent(event)
    self.EventRegistrations[#self.EventRegistrations + 1] = event
end

function M:FireEvent(event, ...)
    local registered = false
    for _, registration in ipairs(self.EventRegistrations) do
        if registration == event then
            registered = true
            break
        end
    end

    if not registered then
        return
    end

    for _, hook in ipairs(self.ScriptHooks) do
        if hook.Event == "OnEvent" then
            hook.Callback(...)
        end
    end
end

return M
