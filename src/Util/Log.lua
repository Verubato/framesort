local addonName, addon = ...
local logPrefix = addonName .. ": "
local warningPrefix = addonName .. " - Warning: "

---Prints a debug message to the chat window if DebugMode is enabled.
---@param msg string
function addon:Debug(msg)
    if addon.Options.DebugEnabled then
        print(logPrefix .. msg)
    end
end

---Prints a warning message to the chat window if DebugMode is enabled.
---@param msg string
function addon:Warning(msg)
    if addon.Options.DebugEnabled then
        print(warningPrefix .. msg)
    end
end
