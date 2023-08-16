local M = {
    NextFrameCallbacks = {},
    CombatEndCallbacks = {},
}

function M:RunNextFrame(callback)
    M.NextFrameCallbacks[#M.NextFrameCallbacks + 1] = callback
end

function M:RunWhenCombatEnds(callback)
    M.CombatEndCallbacks[#M.CombatEndCallbacks + 1] = callback
end

return M
