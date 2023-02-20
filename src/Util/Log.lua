local addonName, addon = ...
local logPrefix = addonName .. ": "

---Prints a debug message to the chat window if DebugMode is enabled.
---@param msg string
function addon:Debug(msg)
    if addon.Options.DebugEnabled then
        print(logPrefix .. msg)
    end
end
