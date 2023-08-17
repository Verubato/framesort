return {
    NextFrameCallbacks = {},
    CombatEndCallbacks = {},
    Reset = function(self)
        self.NextFrameCallbacks = {}
        self.CombatEndCallbacks = {}
    end,
    After = function(_, callback)
        callback()
    end,
}
