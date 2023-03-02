local addonName, addon = ...
local logPrefix = addonName .. ": "
local warningPrefix = addonName .. " - Warning: "

local function Enabled()
    if addon.Options.Version < 5 then
        return addon.Options.DebugEnabled or false
    end

    return addon.Options.Debug.Enabled
end

---Prints a debug message to the chat window if DebugMode is enabled.
---@param msg string
function addon:Debug(msg)
    if Enabled() then
        print(logPrefix .. msg)
    end
end

---Prints a warning message to the chat window if DebugMode is enabled.
---@param msg string
function addon:Warning(msg)
    if Enabled() then
        print(warningPrefix .. msg)
    end
end
